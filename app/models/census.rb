# How many characters each character group has in play, for the census at the
# top of the Character Directory, so new players can see where they're needed.
# "In play" means approved, not retired or on the roster, and played (posted or
# moved) in the last month.
module Census
  RECENT = 30.days

  Row = Struct.new(:group, :count, keyword_init: true)

  def self.rows
    playing = Character.active.where(on_roster_at: nil, status: "approved").where(last_active_at: RECENT.ago..)
    counts = playing.group(:character_group_id).count
    rows = CharacterGroup.ordered.map { |group| Row.new(group: group, count: counts[group.id].to_i) }
    rows << Row.new(group: nil, count: counts[nil]) if counts[nil].to_i.positive?
    rows
  end
end
