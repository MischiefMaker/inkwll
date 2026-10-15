module ApplicationHelper
  # The word players see for one of Inkwll's things, from config/locales/en.yml.
  # term(:room) is "Setting"; term(:room, count: 2) is "Settings".
  def term(name, count: 1)
    t("terms.#{name}", count: count)
  end

  # The game's name from Admin → Game settings, or "Inkwll" until it has one.
  def game_name
    GameSetting.current.game_name || "Inkwll"
  end

  # The game's icon: the one uploaded in Game settings, or the favicon's
  # inkwell. "small" sits beside the name in the top bar, "large" in the
  # front page header.
  def game_icon(size)
    icon = GameSetting.current.icon
    classes = "game-icon game-icon--#{size}"
    icon.attached? && icon.blob.persisted? ? image_tag(icon, alt: "", class: classes) : image_tag("/icon.svg", alt: "", class: "#{classes} game-icon--default")
  end

  # The browser tab title. Pages end theirs with "· Inkwll"; the game's own
  # name replaces it.
  def page_title
    (content_for(:title) || "Inkwll").sub(/Inkwll\z/, game_name)
  end

  # Puts an Area's or Setting's background picture behind the whole page.
  # A Setting without one uses its Area's, or the nearest Area above that has one.
  def page_background(record)
    holder = [ record, *(record.is_a?(Room) ? [ record.area, *record.area.ancestors.reverse ] : record.ancestors.reverse) ]
      .find { |place| place.background.attached? }
    content_for :page_background, "--page-image: url(\"#{url_for(holder.background)}\")" if holder
  end

  # Classes on <body> so a skin can style one page or kind of visitor:
  # "page-scenes page-scenes-show is-logged-in", or "page-admin-bans ... is-staff".
  # Whether the logged-in player plays this character (or owns this record).
  # Guests own nothing, even characters with no player.
  def own?(record)
    current_account.present? && record.account_id == current_account.id
  end

  # Whether the logged-in player can manage this character: their own, or
  # for staff who review applications, one kept for the roster.
  def manages?(character)
    own?(character) || (character.roster_kept? && current_account&.can?(:review_apps)) || false
  end

  def body_classes
    page = "page-#{controller_path.tr("/", "-")}"
    classes = [ page, "#{page}-#{action_name}" ]
    classes << (current_account ? "is-logged-in" : "is-guest")
    classes << "is-staff" if current_account&.staff?
    classes << "can-ban" if current_account&.can?(:ban)
    classes << "is-admin" if controller_path.start_with?("admin/")
    # The ready-made look the game started from, for looks with extra styling
    # of their own, such as skin-mush (app/assets/stylesheets/skin-mush.css).
    classes << "skin-#{GameSetting.current.skin_base}" if GameSetting.current.skin_base
    classes.join(" ")
  end

  # The class and colour for a character's name. A character in a group
  # (a house, a faction) gets the group's colour; skins can override it
  # with .character-group-<id>.
  def character_name_options(character, extra_class = nil)
    group = character&.character_group
    classes = [ extra_class, "character-name", ("character-name--grouped character-group-#{group.id}" if group) ]
    { class: classes.compact.join(" "), style: ("--group-colour: #{group.colour}" if group) }
  end

  # A character's name linked to their profile, in their group's colour.
  def character_name_link(character, extra_class = nil)
    link_to character.name, character_path(character), **character_name_options(character, extra_class)
  end

  # The public profile fields the game shows beside Passages.
  def passage_fields
    @passage_fields ||= ProfileField.where(public: true).where("on_passages OR age_on_passages").ordered.to_a
  end

  # A few lines for a character's pop-up: their first public long-text
  # answer in Demographics, such as Description.
  def mini_profile_blurb(character)
    @mini_profile_field ||= ProfileField.where(section: "demographics", field_type: "long_text", public: true).ordered.first || false
    @mini_profile_field && character.profile_value_for(@mini_profile_field)&.value.presence
  end

  # The short line beside a character's Passages: their group and the
  # fields picked under Admin, Profile fields.
  def character_details(character, css_class)
    return if character.nil?
    parts = [ character.character_group&.name ]
    passage_fields.each do |field|
      value = character.profile_value_for(field)
      next if value&.value.blank?
      parts << case field.field_type
      when "birthday"
        age = IcClock.age(value.as_date)
        # "Age" on its own when the field is set to show only the age.
        if field.age_on_passages? && !field.on_passages? then age && "Age: #{age}"
        else age && "#{field.name}: age #{age}"
        end
      when "date" then value.as_date && "#{field.name}: #{value.as_date.to_fs(:long)}"
      else "#{field.name}: #{value.value.truncate(60)}"
      end
    end
    parts.compact!
    tag.span(safe_join(parts, " · "), class: css_class) if parts.any?
  end
end
