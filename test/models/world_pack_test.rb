require "test_helper"

class WorldPackTest < ActiveSupport::TestCase
  PIXEL = Base64.strict_encode64(Rails.root.join("test/fixtures/files/pixel.png").binread)

  def pack(**overrides)
    WorldPack.new({
      "format" => WorldPack::FORMAT,
      "name" => "Test World",
      "game" => { "name" => "Old Game", "blurb" => "It was the best of times.", "icon" => "pixel" },
      "look" => { "font_body" => "Oswald, sans-serif", "custom_css" => ".x { color: red; }" },
      "areas" => [
        { "name" => "Hogwarts", "summary" => "A school.", "entrance" => "Foyer", "image" => "pixel" },
        { "name" => "Grounds", "parent" => "Hogwarts" }
      ],
      "places" => [
        { "name" => "Foyer", "area" => "Hogwarts", "description" => "A big hall." },
        { "name" => "Lake", "area" => "Grounds", "kind" => "outdoor" }
      ],
      "paths" => [
        { "from" => "Foyer", "to" => "Lake", "direction" => "OUT" },
        { "from" => "Lake", "to" => "Foyer", "kind" => "building" }
      ],
      "wiki_pages" => [ { "title" => "Our Story", "body" => "Once upon a time.", "tags" => [ "Lore" ], "locked" => true } ],
      "boards" => [ { "name" => "Newest News", "was" => "Old News", "who_can_start" => "staff" } ],
      "images" => { "pixel" => { "content_type" => "image/png", "filename" => "pixel.png", "data" => PIXEL } }
    }.merge(overrides.transform_keys(&:to_s)))
  end

  test "parse turns away files that aren't world packs" do
    assert_raises(WorldPack::Invalid) { WorldPack.parse("not json") }
    assert_raises(WorldPack::Invalid) { WorldPack.parse({ "format" => "something else" }.to_json) }
    assert_equal "Test World", WorldPack.parse(pack.data.to_json).name
  end

  test "a pack must name things that exist" do
    assert_raises(WorldPack::Invalid) { pack(places: [ { "name" => "Lost", "area" => "Nowhere" } ], paths: []) }
    assert_raises(WorldPack::Invalid) { pack(paths: [ { "from" => "Foyer", "to" => "Moon" } ]) }
    assert_raises(WorldPack::Invalid) { pack(areas: [ { "name" => "Hogwarts", "icon" => "missing" } ], places: [], paths: []) }
  end

  test "importing sets up the game, areas, places, paths, wiki and boards" do
    ForumBoard.create!(name: "Old News")
    pack.import!(by: accounts(:founder))

    settings = GameSetting.current
    assert_equal "Old Game", settings.game_name
    assert settings.icon.attached?
    assert_equal "Oswald, sans-serif", settings.font_body

    hogwarts = Area.find_by!(name: "Hogwarts")
    assert_equal hogwarts, Area.find_by!(name: "Grounds").parent
    assert hogwarts.image.attached?
    foyer = Room.find_by!(name: "Foyer")
    assert_equal foyer, hogwarts.entrance_room
    assert_equal "outdoor", Room.find_by!(name: "Lake").kind
    assert_equal "OUT", foyer.exits.find_by!(name: "Lake").direction

    page = WikiPage.find_by!(slug: WikiPage.slug_for("Our Story"))
    assert_equal [ "lore" ], page.tags
    assert page.locked_at

    assert ForumBoard.exists?(name: "Newest News", who_can_start: "staff")
    assert_not ForumBoard.exists?(name: "Old News")
  end

  test "importing the same pack twice changes nothing the second time" do
    pack.import!(by: accounts(:founder))
    counts = -> { [ Area.count, Room.count, Exit.count, WikiPage.count, ForumBoard.count, ActiveStorage::Blob.count, WikiRevision.count ] }
    before = counts.call
    pack.import!(by: accounts(:founder))
    assert_equal before, counts.call
    assert pack.preview.none? { |change| change.action == "add" }
  end

  test "The Prologue gets a Path into each top-level area" do
    prologue = Room.create_prologue!
    pack.import!(by: accounts(:founder))
    assert prologue.exits.exists?(destination_room: Room.find_by!(name: "Foyer"))
  end

  test "removing what the pack leaves out keeps only The Prologue, and moves Chapters to The Well of Lost Plots" do
    prologue = Room.create_prologue!
    garden, tower, castle = rooms(:garden).id, rooms(:tower).id, areas(:castle).id
    commons, scene, world = rooms(:commons).id, Scene.where(room: rooms(:commons)).first, areas(:world).id
    pack.import!(by: accounts(:founder), remove_unlisted: true)

    assert Room.exists?(prologue.id)
    assert_not Room.exists?(commons)
    assert_not Room.exists?(garden)
    assert_not Room.exists?(tower)
    assert_not Area.exists?(world)
    assert_not Area.exists?(castle)
    lost = Room.find_by!(name: WorldPack::LOST_PLOTS)
    assert_equal prologue.area, lost.area
    assert_equal lost, scene.reload.room
    assert Room.exists?(name: "Foyer")
  end

  test "characters in a Place that is removed move to The Prologue" do
    prologue = Room.create_prologue!
    character = Character.where(room: rooms(:commons)).first
    character.update_columns(room_id: rooms(:garden).id)
    garden = rooms(:garden).id

    change = pack.preview(remove_unlisted: true).find { |c| c.name == "Garden" }
    assert_equal "remove", change.action
    assert_match "moves to The Prologue", change.note

    pack.import!(by: accounts(:founder), remove_unlisted: true)
    assert_not Room.exists?(garden)
    assert_equal prologue, character.reload.room
  end

  test "the preview lists what would be removed and what stays" do
    changes = pack.preview(remove_unlisted: true)
    assert changes.any? { |c| c.name == "Garden" && c.action == "remove" }
    assert changes.any? { |c| c.name == "The Commons" && c.action == "remove" && c.note.include?(WorldPack::LOST_PLOTS) }
    assert changes.any? { |c| c.name == "Foyer" && c.action == "add" }
  end

  FONT = Base64.strict_encode64("wOF2" + "\0" * 60)

  def font(**overrides)
    { "family" => "Cinzel", "weight" => 700, "style" => "normal", "filename" => "cinzel-bold.woff2", "data" => FONT }.merge(overrides.transform_keys(&:to_s))
  end

  test "a pack's fonts are stored in the game and declared in its stylesheet" do
    pack(fonts: [ font, font(weight: 400, family: "Old Standard TT") ]).import!(by: accounts(:founder))

    settings = GameSetting.current
    assert_equal 2, settings.skin_fonts.count
    css = settings.skin_css
    assert_includes css, %(font-family: "Cinzel")
    assert_includes css, "font-weight: 700"
    assert_includes css, 'format("woff2")'
    assert_match %r{url\("/rails/active_storage/blobs/redirect/}, css
    assert settings.skinned?
  end

  test "importing the same fonts twice keeps one of each" do
    pack(fonts: [ font ]).import!(by: accounts(:founder))
    blob = SkinFont.last.file.blob
    pack(fonts: [ font ]).import!(by: accounts(:founder))

    assert_equal 1, SkinFont.count
    assert_equal blob, SkinFont.last.file.blob
  end

  test "the preview lists fonts" do
    assert pack(fonts: [ font ]).preview.any? { |c| c.kind == "Font" && c.name == "Cinzel 700" && c.action == "add" }
  end

  test "fonts must be small WOFF2 files with plain names" do
    assert_raises(WorldPack::Invalid) { pack(fonts: [ font(data: Base64.strict_encode64("not a font")) ]) }
    assert_raises(WorldPack::Invalid) { pack(fonts: [ font(data: Base64.strict_encode64("wOF2" + "\0" * SkinFont::MAX_SIZE)) ]) }
    assert_raises(WorldPack::Invalid) { pack(fonts: [ font(family: "x\"; } body { display: none") ]) }
    assert_raises(WorldPack::Invalid) { pack(fonts: [ font(weight: 450) ]) }
    assert_raises(WorldPack::Invalid) { pack(fonts: [ font(style: "oblique") ]) }
    assert_raises(WorldPack::Invalid) { pack(fonts: Array.new(WorldPack::MAX_FONTS + 1) { |i| font(family: "Font #{i}") }) }
  end
end
