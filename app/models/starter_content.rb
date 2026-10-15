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
    "Spirit" => [ "Willpower, emotional depth, and the arcane", [ "Ceremonial Magic", "Hedgecraft", "Natural" ] ]
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

  # [name, section, field type, public, required, hint]
  PROFILE_FIELDS = [
    [ "Pronouns", "demographics", "text", true, false, nil ],
    [ "Birthday", "demographics", "birthday", true, false, nil ],
    [ "Occupation", "demographics", "text", true, false, nil ],
    [ "Description", "demographics", "long_text", true, false, "How they look and come across." ],
    [ "Background", "application", "long_text", true, true, "Where they come from and what brought them here." ],
    [ "Personality", "application", "long_text", true, false, "How they think, act and get along with others." ],
    [ "Goals", "application", "long_text", false, false, "What they want. Only you and staff can see this." ]
  ].freeze

  def self.install!
    install_soul!
    install_bnbs!
    install_profile_fields!
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
    PROFILE_FIELDS.each_with_index do |(name, section, type, shown, required, hint), position|
      ProfileField.create!(name: name, section: section, field_type: type, public: shown, required: required, hint: hint, position: position)
    end
  end
end
