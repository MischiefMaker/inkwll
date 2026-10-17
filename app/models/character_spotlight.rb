# The front page's character spotlight: one character a day, picked at random
# from those played in the last month, so it shows off characters who aren't
# in the popular crowd. The same character shows all day, for everyone.
module CharacterSpotlight
  RECENT = 30.days
  LINE_LENGTH = 160

  def self.enabled? = GameSetting.current.character_spotlight?

  def self.today(on = Date.current)
    candidates = Character.active.where(on_roster_at: nil).where(last_active_at: RECENT.ago..)
    candidates = candidates.approved if GameSetting.current.approval_required?
    ids = candidates.order(:id).pluck(:id)
    return if ids.empty?
    Character.find(ids[Random.new(on.jd).rand(ids.size)])
  end

  # The first public written answer on their profile, cut short.
  def self.line_for(character)
    fields = ProfileField.where(public: true, field_type: %w[ text long_text ]).ordered
    value = character.profile_values.where(profile_field: fields).where.not(value: [ nil, "" ])
      .joins(:profile_field).order("profile_fields.position, profile_fields.id").first&.value
    value&.squish&.truncate(LINE_LENGTH, separator: " ")
  end
end
