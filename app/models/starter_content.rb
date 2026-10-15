# The ready-to-play defaults a new game ships with, so character creation
# works before staff set anything up (owner, 2026-10-15): SOUL's Aspects and
# Skills (taken from the owner's ares-soul-plugin), a small starter
# catalogue of Boons and Banes, and a few profile and application fields.
# Each part is only added when the game has none of it yet, so staff
# changes are never overwritten. Change any of it in the admin panel.
module StarterContent
  ASPECTS = {
    "Body" => [ "Physical capability and endurance", %w[ Strength Speed Stamina ] ],
    "Mind" => [ "Intellect, perception, and reason", %w[ Intelligence Learning Wit ] ],
    "Spirit" => [ "Willpower, emotional depth, and the arcane", [ "Ceremonial Magic", "Hedgecraft", "Natural Magic" ] ]
  }.freeze

  BOONS = {
    "Contacts" => "Friends in useful places who can pass on news, favours or introductions.",
    "Wealthy" => "Money to spare, and the doors it opens.",
    "Keen Senses" => "Notices what others miss: a sound, a smell, a face in the crowd.",
    "Lucky" => "Things have a way of working out, more often than they should.",
    "Iron Will" => "Hard to frighten, persuade or bend.",
    "Well-Travelled" => "Has been far and wide, and picked up languages, customs and stories."
  }.freeze

  BANES = {
    "Enemy" => "Someone, or something, wants them gone.",
    "Poor" => "Money is always short, and it shows.",
    "Phobia" => "A deep fear of something specific, hard to master in the moment.",
    "Cursed" => "Bad luck, or worse, follows them around.",
    "Hot-Tempered" => "Quick to anger, and slow to cool down.",
    "Old Wound" => "An injury that never quite healed, and flares up at the worst times."
  }.freeze

  # [name, section, field type, public, required, hint, Inkling type it starts]
  PROFILE_FIELDS = [
    [ "Pronouns", "demographics", "text", true, false, nil ],
    [ "Birthday", "demographics", "birthday", true, false, nil ],
    [ "Occupation", "demographics", "text", true, false, nil ],
    [ "Description", "demographics", "long_text", true, false, "How they look and come across." ],
    [ "Background", "application", "long_text", true, true, "Where they come from and what brought them here." ],
    [ "Personality", "application", "long_text", true, false, "How they think, act and get along with others." ],
    [ "Goals", "application", "long_text", false, false, "What they want. Only you and staff can see this.", "goal" ],
    [ "Secrets", "application", "long_text", false, false, "Something they are hiding. Only you and staff can see this.", "secret" ]
  ].freeze

  # [from, to, name, what it means]. Written for a 0-10 scale; staff change it
  # in Admin → SOUL.
  RATING_GUIDE = [
    [ 0, 0, "Untrained", "No real knowledge or practice." ],
    [ 1, 2, "Novice", "A beginner or an amateur. Can manage easy things on a good day." ],
    [ 3, 4, "Competent", "A typical trained adult. Reliable at everyday tasks." ],
    [ 5, 6, "Skilled", "A professional, good enough to make a living from it. The top of what most people reach." ],
    [ 7, 8, "Exceptional", "Among the best in a city or a field. Remarkable, but still human." ],
    [ 9, 10, "Superhuman", "Beyond what ordinary people can do: legend, magic or something not quite mortal." ]
  ].freeze

  def self.install!
    install_rating_guide!
    install_soul!
    install_bnbs!
    install_profile_fields!
  end

  def self.install_rating_guide!
    return if Soul::RatingGuide.exists?
    RATING_GUIDE.each_with_index do |(low, high, name, description), position|
      Soul::RatingGuide.create!(low: low, high: high, name: name, description: description, position: position)
    end
  end

  def self.install_soul!
    return if Soul::Aspect.exists?
    ASPECTS.each_with_index do |(name, (description, skills)), position|
      aspect = Soul::Aspect.create!(name: name, description: description, position: position)
      skills.each_with_index { |skill, i| aspect.skills.create!(name: skill, position: i) }
    end
  end

  def self.install_bnbs!
    return if Soul::Bnb.exists?
    BOONS.each { |name, description| Soul::Bnb.create!(kind: "boon", name: name, description: description) }
    BANES.each { |name, description| Soul::Bnb.create!(kind: "bane", name: name, description: description) }
  end

  def self.install_profile_fields!
    return if ProfileField.exists?
    PROFILE_FIELDS.each_with_index do |(name, section, type, shown, required, hint, inkling_kind), position|
      ProfileField.create!(name: name, section: section, field_type: type, public: shown, required: required, hint: hint, position: position, inkling_kind: inkling_kind, player_can_edit: name != "Background")
    end
  end
end
