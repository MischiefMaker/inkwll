# Game-wide switches that each game can change from the admin panel.
# There is only ever one row; use GameSetting.current.
class GameSetting < ApplicationRecord
  validates :turn_minutes, numericality: { only_integer: true, in: 1..120 }
  validates :idle_days, numericality: { only_integer: true, in: 1..365 }
  validates :auto_finish_days, numericality: { only_integer: true, in: 1..3650 }
  validate :auto_finish_after_idle

  def self.current
    first || create!
  end

  private
    def auto_finish_after_idle
      errors.add(:auto_finish_days, "must be more than the idle days") if auto_finish_days.to_i <= idle_days.to_i
    end
end
