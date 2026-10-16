# Game-wide switches that each game can change from the admin panel.
# There is only ever one row; use GameSetting.current.
class GameSetting < ApplicationRecord
  include Skin

  # The game's own icon, beside its name in the top bar and on the front
  # page. Without one, the favicon's inkwell is used.
  has_one_attached :icon
  attribute :remove_icon, :boolean, default: false
  after_save { icon.purge_later if remove_icon && icon.attached? }
  validate :icon_is_a_reasonable_picture

  # Where a character's name, icon and demographics sit on their profile.
  PROFILE_BOXES = %w[ top side ].freeze
  validates :profile_box, inclusion: { in: PROFILE_BOXES }

  # How a Chapter page looks (owner, 2026-10-15). Chat is the original
  # list of posts; Manuscript reads like a book page; Forum gives each
  # Passage an author panel. Manuscript has two portrait sizes of its own:
  # the cast under the title, and the portrait beside each Passage.
  CHAPTER_LAYOUTS = %w[ manuscript chat forum ].freeze
  PORTRAIT_SIZES = %w[ large small ].freeze
  validates :chapter_layout, inclusion: { in: CHAPTER_LAYOUTS }
  validates :chapter_cast_portraits, :chapter_passage_portraits, inclusion: { in: PORTRAIT_SIZES }
  validates :turn_minutes, numericality: { only_integer: true, in: 1..120 }
  validates :idle_days, numericality: { only_integer: true, in: 1..365 }
  validates :auto_finish_days, numericality: { only_integer: true, in: 1..3650 }
  validate :auto_finish_after_idle
  normalizes :weather, with: ->(w) { w.squish.presence }
  validates :weather, length: { maximum: 200 }
  normalizes :game_name, with: ->(name) { name.squish.presence }
  normalizes :game_blurb, with: ->(text) { text.strip.presence }
  validates :game_name, length: { maximum: 80 }
  validates :game_blurb, length: { maximum: 3_000 }
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
    date = value.is_a?(Date) ? value : (Date.iso8601(value.to_s, Date::GREGORIAN) rescue nil)
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

  # Remembered for the rest of the request, since nearly every page asks many
  # times. Saving a change forgets it.
  def self.current
    Current.game_setting ||= first || create!
  end

  after_save { Current.game_setting = nil }
  after_destroy { Current.game_setting = nil }

  private
    def auto_finish_after_idle
      errors.add(:auto_finish_days, "must be more than the idle days") if auto_finish_days.to_i <= idle_days.to_i
    end

  private
    def icon_is_a_reasonable_picture
      return unless icon.attached? && attachment_changes["icon"]
      errors.add(:icon, "must be a picture (PNG, JPEG, GIF or WebP)") unless icon.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
      errors.add(:icon, "must be smaller than 5 MB") if icon.blob.byte_size > 5.megabytes
    end
end
