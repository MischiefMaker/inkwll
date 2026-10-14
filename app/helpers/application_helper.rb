module ApplicationHelper
  # The word players see for one of Inkwll's things, from config/locales/en.yml.
  # term(:room) is "Setting"; term(:room, count: 2) is "Settings".
  def term(name, count: 1)
    t("terms.#{name}", count: count)
  end

  # Classes on <body> so a skin can style one page or kind of visitor:
  # "page-scenes page-scenes-show is-logged-in", or "page-admin-bans ... is-staff".
  def body_classes
    page = "page-#{controller_path.tr("/", "-")}"
    classes = [ page, "#{page}-#{action_name}" ]
    classes << (current_account ? "is-logged-in" : "is-guest")
    classes << "is-staff" if current_account&.staff?
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
    @passage_fields ||= ProfileField.where(on_passages: true, public: true).ordered.to_a
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
      when "birthday" then (age = IcClock.age(value.as_date)) && "#{field.name}: age #{age}"
      when "date" then value.as_date && "#{field.name}: #{value.as_date.to_fs(:long)}"
      else "#{field.name}: #{value.value.truncate(60)}"
      end
    end
    parts.compact!
    tag.span(safe_join(parts, " · "), class: css_class) if parts.any?
  end
end
