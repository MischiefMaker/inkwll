# The weekly scene bounty: a few characters each player is paid (in SOUL XP)
# to write with. Characters new in the last two weeks are always on it, so
# newcomers get noticed; the rest are picked at random from characters played
# lately. The list is made the first time the player looks that week (on My
# Chapters) and stays the same until Monday. Never the player's own characters.
class SceneBounty < ApplicationRecord
  SIZE = 5
  NEW_FOR = 14.days
  RECENT = 30.days

  belongs_to :account

  def self.enabled? = Soul.enabled? && award.positive?
  def self.award = Soul::Rules.config.dig("xp", "bounty_award").to_i

  def self.week_of(time = Time.current) = time.to_date.beginning_of_week

  def self.for(account, time = Time.current)
    find_or_create_by!(account: account, week_of: week_of(time)) do |bounty|
      bounty.character_ids = pick_for(account)
    end
  rescue ActiveRecord::RecordNotUnique
    find_by!(account: account, week_of: week_of(time))
  end

  def self.pick_for(account)
    playable = Character.active.where(on_roster_at: nil).where.not(account_id: account.id)
    playable = playable.approved if GameSetting.current.approval_required?
    newcomers = playable.where(created_at: NEW_FOR.ago..).order("RANDOM()").limit(SIZE).pluck(:id)
    others = playable.where(last_active_at: RECENT.ago..).where.not(id: newcomers)
      .order("RANDOM()").limit(SIZE - newcomers.size).pluck(:id)
    newcomers + others
  end

  def characters = Character.where(id: character_ids).order(:name)

  # A finished Chapter pays each character who posted in it the bounty for
  # every character on their player's list this week who also posted. Each
  # pairing pays once a week.
  def self.pay_for!(scene)
    return unless enabled?
    posted = scene.poses.story.pluck(:character_id).compact.uniq
    week = week_of(scene.finished_at)
    Character.where(id: posted).includes(:account).find_each do |character|
      next unless character.can_play?
      bounty = find_by(account_id: character.account_id, week_of: week) or next
      Character.where(id: bounty.character_ids & posted).find_each do |target|
        character.award_xp!(award, source: "bounty", key: "bounty:#{week}:#{character.id}:#{target.id}",
          note: "Wrote with #{target.name} in #{scene.title}")
      end
    end
  end
end
