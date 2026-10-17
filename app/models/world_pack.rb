# A world pack: a whole game world in one file, for setting up a Well
# from an old game without building it by hand (Admin → Import a world).
# It is JSON, with any pictures inside it, and can hold:
#
#   game        the game's name, front-page blurb and icon
#   look        colours, fonts, extra CSS and the Look pictures
#   areas       Areas, nested by naming their parent
#   places      Places, each in an Area
#   paths       Paths between Places, by name
#   wiki_pages  wiki pages, by title
#   boards      forum boards, by name ("was" renames an existing board)
#   images      the pictures, base64, which everything else names by key
#   fonts       web fonts (WOFF2, base64) the game's look can name, kept with
#               the game rather than with Inkwll (see SkinFont)
#
# Importing only adds and updates: things are matched by name, so running
# the same pack twice changes nothing the second time. With remove_unlisted,
# Areas, Places and Paths the pack doesn't mention are taken away too, except
# The Prologue. Characters in a Place that goes move to The Prologue, and its
# Chapters to The Well of Lost Plots, in the Out of Character Area. Wiki pages,
# boards and characters are never removed. The format is in
# docs/world-packs.md.
class WorldPack
  FORMAT = "inkwll-world-pack"
  MAX_SIZE = 25.megabytes
  IMAGE_TYPES = %w[ image/png image/jpeg image/gif image/webp ].freeze
  LOST_PLOTS = "The Well of Lost Plots"
  MAX_FONTS = 24

  class Invalid < StandardError; end

  # One line of the preview: what kind of thing, its name, and whether the
  # import adds it, changes it, or removes it.
  Change = Data.define(:kind, :name, :action, :note)

  attr_reader :data, :name

  def self.parse(text)
    raise Invalid, "The file is bigger than #{MAX_SIZE / 1.megabyte} MB." if text.bytesize > MAX_SIZE
    data = JSON.parse(text)
    raise Invalid, "That isn't a world pack." unless data.is_a?(Hash) && data["format"] == FORMAT
    new(data)
  rescue JSON::ParserError
    raise Invalid, "That file isn't a world pack (it isn't JSON)."
  end

  def initialize(data)
    @data = data
    @name = data["name"].to_s.presence || "a world pack"
    check!
  end

  def areas = list("areas")
  def places = list("places")
  def paths = list("paths")
  def wiki_pages = list("wiki_pages")
  def boards = list("boards")
  def fonts = list("fonts")
  def game = data["game"].is_a?(Hash) ? data["game"] : {}
  def look = data["look"].is_a?(Hash) ? data["look"] : {}

  # Everything the import would do, without doing it.
  def preview(remove_unlisted: false)
    changes = []
    changes << Change.new("Game", "Name and front page text", "change", nil) if game.any?
    changes << Change.new("Look", "Colours, fonts, extra CSS and pictures", "change", nil) if look.any?
    fonts.each { |f| changes << Change.new("Font", font_name(f), font_for(f) ? "change" : "add", nil) }
    areas.each { |a| changes << Change.new(Term[:area], a["name"], Area.exists?(name: a["name"]) ? "change" : "add", a["parent"]) }
    places.each do |p|
      found = Room.joins(:area).exists?(name: p["name"], areas: { name: p["area"] })
      changes << Change.new(Term[:room], p["name"], found ? "change" : "add", p["area"])
    end
    added_paths = paths.count { |p| !existing_path(p) }
    changes << Change.new(Term[:exit, count: 2], "#{paths.size} #{Term[:exit, count: paths.size].downcase}", added_paths.zero? ? "change" : "add", "#{added_paths} new") if paths.any?
    wiki_pages.each { |w| changes << Change.new("Wiki page", w["title"], WikiPage.exists?(slug: WikiPage.slug_for(w["title"])) ? "change" : "add", nil) }
    boards.each { |b| changes << Change.new("Board", b["name"], board_for(b) ? "change" : "add", (b["was"] if b["was"].present? && !ForumBoard.exists?(name: b["name"]))) }
    if remove_unlisted
      removals.each { |kind, record, kept, note| changes << Change.new(kind, record.name, kept ? "keep" : "remove", kept || note) }
    end
    changes
  end

  # Does it all, in one go: if anything fails, nothing is changed.
  def import!(by:, remove_unlisted: false)
    ApplicationRecord.transaction do
      import_game
      import_look
      import_fonts
      area_records = import_areas
      place_records = import_places(area_records)
      import_paths(place_records)
      set_entrances(area_records, place_records)
      remove_unlisted_world if remove_unlisted
      link_prologue(area_records)
      import_wiki(by)
      import_boards
    end
    true
  end

  private
    def list(key) = Array(data[key]).select { |item| item.is_a?(Hash) }

    def check!
      areas.each { |a| raise Invalid, "Every #{Term[:area]} needs a name." if a["name"].blank? }
      area_names = areas.map { |a| a["name"] }
      places.each do |p|
        raise Invalid, "Every #{Term[:room]} needs a name and an #{Term[:area]}." if p["name"].blank? || p["area"].blank?
        unless area_names.include?(p["area"]) || Area.exists?(name: p["area"])
          raise Invalid, "#{p["name"]} is in #{p["area"]}, which isn't in the pack or the game."
        end
      end
      place_names = places.map { |p| p["name"] }
      paths.each do |p|
        [ p["from"], p["to"] ].each do |end_name|
          raise Invalid, "A #{Term[:exit].downcase} goes to or from #{end_name.inspect}, which isn't a #{Term[:room]} in the pack." unless place_names.include?(end_name)
        end
      end
      wiki_pages.each { |w| raise Invalid, "Every wiki page needs a title." if w["title"].blank? }
      boards.each { |b| raise Invalid, "Every board needs a name." if b["name"].blank? }
      picture_keys.each { |key| raise Invalid, "The picture #{key.inspect} isn't in the pack." unless images.key?(key) }
      raise Invalid, "A pack can bring at most #{MAX_FONTS} fonts." if fonts.size > MAX_FONTS
      fonts.each do |f|
        raise Invalid, "The font #{font_name(f).inspect} needs a family name (letters, numbers, spaces and hyphens)." unless f["family"].to_s.squish.match?(/\A[\p{L}\p{N} -]{1,60}\z/)
        raise Invalid, "The font #{font_name(f).inspect} has a weight that isn't 100 to 900." unless (f["weight"] || 400).to_i.in?(SkinFont::WEIGHTS)
        raise Invalid, "The font #{font_name(f).inspect} must be normal or italic." unless (f["style"].presence || "normal").in?(SkinFont::STYLES)
        font_bytes(f)
      end
    end

    def font_name(font) = [ font["family"], (font["weight"] unless font["weight"].to_i == 400), (font["style"] unless font["style"].blank? || font["style"] == "normal") ].compact.join(" ")

    # The font file, checked: WOFF2 (it starts with "wOF2") and not too big.
    def font_bytes(font)
      bytes = Base64.decode64(font["data"].to_s)
      raise Invalid, "The font #{font_name(font).inspect} must be a WOFF2 file." unless bytes.start_with?("wOF2")
      raise Invalid, "The font #{font_name(font).inspect} is bigger than #{SkinFont::MAX_SIZE / 1.kilobyte} KB." if bytes.bytesize > SkinFont::MAX_SIZE
      bytes
    end

    def font_attributes(font)
      { family: font["family"].to_s.squish, weight: (font["weight"] || 400).to_i, style: font["style"].presence || "normal" }
    end

    def font_for(font) = GameSetting.current.skin_fonts.find_by(font_attributes(font))

    def images = data["images"].is_a?(Hash) ? data["images"] : {}

    def picture_keys
      keys = [ *areas, *places, *boards ].flat_map { |item| item.values_at("icon", "image", "background") }
      keys += (look["pictures"] || {}).values << game["icon"]
      keys.compact.uniq
    end

    def attach(record, picture, key)
      return if key.blank?
      image = images.fetch(key)
      type = image["content_type"].to_s
      raise Invalid, "The picture #{key} must be a PNG, JPEG, GIF or WebP." unless type.in?(IMAGE_TYPES)
      bytes = Base64.decode64(image["data"].to_s)
      raise Invalid, "The picture #{key} is bigger than 5 MB." if bytes.bytesize > DescribedWithImage::MAX_IMAGE_SIZE
      # Skip pictures that are already there, so a second import doesn't
      # upload everything again.
      current = record.public_send(picture)
      return if current.attached? && current.blob.checksum == OpenSSL::Digest::MD5.base64digest(bytes)
      # Uploaded straight away rather than when the record is saved, so it
      # can't be lost if the record is saved or reloaded again later.
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(bytes), filename: image["filename"].presence || "#{key}.#{type.split("/").last}", content_type: type)
      current.attach(blob)
    end

    def import_fonts
      return if fonts.empty?
      settings = GameSetting.current
      fonts.each do |font|
        bytes = font_bytes(font)
        record = settings.skin_fonts.find_or_initialize_by(font_attributes(font))
        # Skip a font that is already there, as pictures are skipped.
        next if record.persisted? && record.file.attached? && record.file.blob.checksum == OpenSSL::Digest::MD5.base64digest(bytes)
        blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(bytes), filename: font["filename"].presence || "#{record.family.parameterize}.woff2", content_type: SkinFont::CONTENT_TYPE, identify: false)
        record.file.attach(blob)
        record.save!
      end
      # The skin stylesheet's address changes with this, so browsers fetch it again.
      settings.update!(updated_at: Time.current)
    end

    def import_game
      return if game.empty?
      settings = GameSetting.current
      settings.game_name = game["name"] if game.key?("name")
      settings.game_blurb = game["blurb"] if game.key?("blurb")
      attach(settings, :icon, game["icon"])
      settings.save!
    end

    def import_look
      return if look.empty?
      settings = GameSetting.current
      # The pack's look replaces the game's, so nothing of an earlier look
      # (such as the Old-school MUSH one, with its <OOC> labels) is left behind.
      settings.assign_attributes(skin_base: nil, skin_colours: {}, skin_dark_colours: {}, skin_dark_mode: true, font_body: nil, font_heading: nil, custom_css: nil)
      settings.apply_preset(look["preset"]) if GameSetting::Skin::PRESETS.key?(look["preset"])
      settings.skin_colours = settings.skin_colours.merge(look["colours"]) if look["colours"].is_a?(Hash)
      settings.skin_dark_colours = look["dark_colours"] if look["dark_colours"].is_a?(Hash)
      settings.skin_dark_mode = look["dark_mode"] if look.key?("dark_mode")
      %w[ font_body font_heading custom_css ].each { |field| settings[field] = look[field] if look.key?(field) }
      (look["pictures"] || {}).each do |picture, key|
        attach(settings, picture, key) if GameSetting::Skin::PICTURES.key?(picture)
      end
      settings.look_chosen_at ||= Time.current
      settings.updated_at = Time.current
      settings.save!
    end

    # Parents first, so every Area's parent exists when it is saved.
    def import_areas
      records = {}
      pending = areas.dup
      until pending.empty?
        ready = pending.select { |a| a["parent"].blank? || records.key?(a["parent"]) || (!areas.any? { |o| o["name"] == a["parent"] } && Area.exists?(name: a["parent"])) }
        raise Invalid, "Some #{Term[:area, count: 2]} are inside each other in a loop." if ready.empty?
        ready.each do |a|
          area = Area.find_or_initialize_by(name: a["name"])
          area.parent = a["parent"].present? ? (records[a["parent"]] || Area.find_by!(name: a["parent"])) : nil
          area.assign_attributes(a.slice("summary", "description", "position").compact)
          DescribedWithImage::PICTURES.each { |picture| attach(area, picture, a[picture.to_s]) }
          area.save!
          records[a["name"]] = area
        end
        pending -= ready
      end
      records
    end

    def import_places(area_records)
      places.to_h do |p|
        area = area_records[p["area"]] || Area.find_by!(name: p["area"])
        room = Room.find_or_initialize_by(name: p["name"], area: area)
        room.assign_attributes(p.slice("summary", "description", "kind").compact)
        DescribedWithImage::PICTURES.each { |picture| attach(room, picture, p[picture.to_s]) }
        room.save!
        [ p["name"], room ]
      end
    end

    def existing_path(p)
      Exit.joins(:source_room).find_by(name: p["name"].presence || p["to"], rooms: { name: p["from"] })
    end

    def import_paths(place_records)
      paths.each do |p|
        from = place_records.fetch(p["from"])
        path = from.exits.find_or_initialize_by(name: (p["name"].presence || p["to"]).squish.first(40))
        path.assign_attributes(destination_room: place_records.fetch(p["to"]), kind: p["kind"].presence || "street",
          direction: p["direction"], number: p["number"])
        path.save!
      end
    end

    def set_entrances(area_records, place_records)
      areas.each do |a|
        next if a["entrance"].blank?
        area_records.fetch(a["name"]).update!(entrance_room: place_records.fetch(a["entrance"]))
      end
    end

    # The Prologue leads into the story: give it a Path to each top-level
    # Area in the pack, named after the Place it leads to.
    def link_prologue(area_records)
      prologue = Room.find_by(name: Room::PROLOGUE) or return
      area_records.values.select { |area| area.parent_id.nil? }.each do |area|
        entrance = area.reload.entrance or next
        next if prologue.exits.exists?(destination_room: entrance)
        prologue.exits.create!(destination_room: entrance, name: unique_path_name(prologue, entrance.name))
      end
    end

    def unique_path_name(room, name)
      base = name.first(40)
      return base unless room.exits.exists?(name: base)
      (2..).each { |n| candidate = "#{base.first(36)} (#{n})"; return candidate unless room.exits.exists?(name: candidate) }
    end

    # [kind, record, reason it is kept or nil, note] for everything the pack
    # leaves out. Before a Place goes, its characters move to The Prologue and
    # its Chapters to The Well of Lost Plots, so no story is lost.
    def removals
      place_keys = places.map { |p| [ p["name"], p["area"] ] }
      area_names = areas.map { |a| a["name"] }
      path_keys = paths.map { |p| [ p["from"], (p["name"].presence || p["to"]).squish.first(40) ] }
      prologue = Room.find_by(name: Room::PROLOGUE)
      lost_plots = Room.find_by(name: LOST_PLOTS)
      people = Character.where.not(room_id: nil).group(:room_id).count
      chapters = Scene.group(:room_id).count

      rooms = Room.includes(:area).reject { |room| place_keys.include?([ room.name, room.area.name ]) }
      kept_rooms = rooms.select { |room| room == prologue || room == lost_plots }
      rooms_out = rooms - kept_rooms
      kept_area_ids = (Room.where.not(id: rooms_out.map(&:id)).pluck(:area_id) + [ prologue&.area_id ]).compact
      kept_area_ids += Area.where(id: kept_area_ids).flat_map(&:ancestors).map(&:id)
      areas_out = Area.where.not(name: area_names).reject { |area| kept_area_ids.include?(area.id) }
      kept_areas = Area.where.not(name: area_names).select { |area| kept_area_ids.include?(area.id) }

      paths_out = Exit.includes(:source_room, :destination_room).reject do |exit|
        path_keys.include?([ exit.source_room.name, exit.name ]) || exit.source_room == prologue ||
          rooms_out.include?(exit.source_room) || rooms_out.include?(exit.destination_room)
      end

      room_rows = rooms.map do |room|
        if room == prologue
          [ Term[:room], room, "the starting #{Term[:room].downcase}", nil ]
        elsif room == lost_plots
          [ Term[:room], room, "keeps #{Term[:scene, count: 2].downcase} from removed #{Term[:room, count: 2].downcase}", nil ]
        else
          moves = []
          moves << "#{people[room.id]} #{people[room.id] == 1 ? "character moves" : "characters move"} to #{Room::PROLOGUE}" if people[room.id].to_i.positive?
          moves << "#{chapters[room.id]} #{Term[:scene, count: chapters[room.id]].downcase} #{chapters[room.id] == 1 ? "moves" : "move"} to #{LOST_PLOTS}" if chapters[room.id].to_i.positive?
          [ Term[:room], room, nil, moves.join("; ").presence ]
        end
      end
      room_rows +
        areas_out.map { |area| [ Term[:area], area, nil, nil ] } +
        kept_areas.map { |area| [ Term[:area], area, "still holds #{Term[:room, count: 2].downcase} that stay", nil ] } +
        paths_out.map { |exit| [ Term[:exit], exit, nil, nil ] }
    end

    def remove_unlisted_world
      out = removals.reject { |_, _, kept, _| kept }.map { |_, record, _, _| record }
      out.grep(Exit).each(&:destroy!)
      rooms = out.grep(Room)
      if Character.where(room_id: rooms.map(&:id)).exists?
        prologue = Room.find_by(name: Room::PROLOGUE) || Room.create_prologue!
        Character.where(room_id: rooms.map(&:id)).update_all(room_id: prologue.id, updated_at: Time.current)
      end
      if Scene.where(room_id: rooms.map(&:id)).exists?
        Scene.where(room_id: rooms.map(&:id)).update_all(room_id: lost_plots_room.id, updated_at: Time.current)
      end
      # Rooms the removed ones were the entrance of stop being one.
      Area.where(entrance_room_id: rooms.map(&:id)).update_all(entrance_room_id: nil)
      RememberedCharacter.where(context_type: "Room", context_id: rooms.map(&:id)).delete_all
      rooms.each { |room| room.reload.destroy! }
      # Innermost Areas first.
      out.grep(Area).sort_by { |area| -area.ancestors.size }.each { |area| area.reload.destroy! }
    end

    # Where Chapters go when their Place is removed: a Place in the Out of
    # Character Area, beside The Prologue (owner).
    def lost_plots_room
      Room.find_by(name: LOST_PLOTS) || begin
        area = (Room.find_by(name: Room::PROLOGUE) || Room.create_prologue!).area
        area.rooms.create!(name: LOST_PLOTS, description: <<~TEXT.strip)
          Stories whose #{Term[:room, count: 2].downcase} have vanished from the world wash up here, still readable, every page intact.
        TEXT
      end
    end

    def import_wiki(by)
      wiki_pages.each do |w|
        page = WikiPage.find_or_initialize_by(slug: WikiPage.slug_for(w["title"]))
        page.title = w["title"]
        page.body = w["body"].to_s
        page.tags = Array(w["tags"]).map { |tag| tag.to_s.downcase.first(30) }.uniq.first(20) if w.key?("tags")
        page.menu_position = w["menu_position"] if w.key?("menu_position")
        page.locked_at = (w["locked"] ? (page.locked_at || Time.current) : nil) if w.key?("locked")
        next if page.persisted? && !page.changed?
        page.save_revision!(by: by, summary: "Imported from #{name}")
      end
    end

    def board_for(b)
      ForumBoard.find_by(name: b["name"]) || (ForumBoard.find_by(name: b["was"]) if b["was"].present?)
    end

    def import_boards
      boards.each do |b|
        board = board_for(b) || ForumBoard.new
        board.name = b["name"]
        board.assign_attributes(b.slice("description", "position", "who_can_start", "who_can_reply").compact)
        ForumBoard::PICTURES.each { |picture| attach(board, picture, b[picture.to_s]) }
        board.save!
      end
    end
end
