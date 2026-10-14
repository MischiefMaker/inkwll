# Game-wide switches that each game can change from the admin panel.
# There is only ever one row; use GameSetting.current.
class GameSetting < ApplicationRecord
  validates :turn_minutes, numericality: { only_integer: true, in: 1..120 }
  validates :idle_days, numericality: { only_integer: true, in: 1..365 }
  validates :auto_finish_days, numericality: { only_integer: true, in: 1..3650 }
  validate :auto_finish_after_idle
  validates :roster_idle_days, numericality: { only_integer: true, in: 7..3650 }
  validates :ic_days_per_day, numericality: { greater_than: 0, less_than_or_equal_to: 365 }

  # "Today's date in the game", as set on the settings page. Setting it
  # restarts the game clock from now (see IcClock).
  def ic_today
    IcClock.today(self) if ic_anchor_date
  end

  def ic_today=(value)
    if value.blank?
      self.ic_anchor_date = self.ic_anchor_at = nil
      return
    end
    date = value.is_a?(Date) ? value : (Date.iso8601(value.to_s) rescue nil)
    return if date.nil? || date == ic_today
    self.ic_anchor_date = date
    self.ic_anchor_at = Time.current
  end

  # Changing the speed keeps today's game date and runs on from now.
  def ic_days_per_day=(value)
    if ic_anchor_date && !ic_anchor_date_changed? && value.to_d != ic_days_per_day.to_d
      self.ic_anchor_date = IcClock.today(self)
      self.ic_anchor_at = Time.current
    end
    super
  end

  def self.current
    first || create!
  end

  private
    def auto_finish_after_idle
      errors.add(:auto_finish_days, "must be more than the idle days") if auto_finish_days.to_i <= idle_days.to_i
    end
end
