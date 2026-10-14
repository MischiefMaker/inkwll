# Gives every approved character their weekly SOUL XP, once per week.
class WeeklyXpJob < ApplicationJob
  def perform(now = Time.current)
    return unless Soul.enabled? && (amount = Soul::Rules.weekly_award).positive?

    week = now.to_date.cweek
    year = now.to_date.cwyear
    median = Character.median_xp_earned
    Character.where(status: "approved").find_each do |character|
      character.award_xp!(amount, source: "weekly", key: "weekly:#{year}-#{week}:#{character.id}", catchup: true, median: median)
    end
  end
end
