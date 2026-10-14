# A player's login. Characters belong to an account and have no login of their own.
#
# The player name (display_name) is the one name a player has: it is shown in
# the OOC chat and also used to log in, ignoring capitals. `username` is just
# the lowercase copy used for logging in.
class Account < ApplicationRecord
  # Staff levels, lowest first. Players are not staff. Storyteller is a separate
  # flag, not a level. Players see these names through config/locales/en.yml.
  STAFF_LEVELS = { player: 0, page: 1, scribe: 2, wellkeeper: 3 }.freeze

  # Jobs a Page can be given. Scribes and Wellkeepers can do all of them.
  JOB_FLAGS = %w[ build app ].freeze

  # How often a player is emailed about new activity (see Notifier).
  # every_time: every time. when_away: only when not logged in.
  # after_days: only after being away for some days.
  EMAIL_NOTIFICATIONS = %w[ off every_time when_away after_days ].freeze

  # When browser pop-ups appear: off, all (every new Passage), my_turn, or
  # after_minutes (once something has sat unread for browser_notify_minutes).
  BROWSER_NOTIFICATIONS = %w[ off all my_turn after_minutes ].freeze

  # Changing the email address makes old "stop these emails" links stop working.
  generates_token_for(:unsubscribe) { email }

  has_secure_password
  validates :password, length: { minimum: 8, maximum: 72 }, allow_nil: true
  has_many :sessions, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :remembered_characters, dependent: :delete_all
  has_many :saved_places, dependent: :delete_all
  has_many :conversation_members, dependent: :destroy
  has_many :ooc_messages, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :account_warnings, dependent: :destroy
  has_many :bans, dependent: :destroy
  belongs_to :active_character, class_name: "Character", optional: true

  enum :staff_level, STAFF_LEVELS, default: :player, validate: true

  normalizes :display_name, with: ->(n) { n.strip }
  normalizes :email, with: ->(e) { e.strip.downcase.presence }

  before_validation { self.username = display_name&.downcase }

  validates :display_name, presence: true, length: { maximum: 30 },
    format: { with: /\A[A-Za-z0-9_]+\z/, message: "can only use letters, numbers and underscores" }
  validate :player_name_is_free
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :email, presence: true, if: -> { GameSetting.current.email_required? }
  validates :email, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :email_notifications, inclusion: { in: EMAIL_NOTIFICATIONS }
  validates :browser_notifications, inclusion: { in: BROWSER_NOTIFICATIONS }
  validates :email_after_days, numericality: { only_integer: true, in: 1..60 }
  validates :browser_notify_minutes, numericality: { only_integer: true, in: 1..240 }
  validate :email_needed_for_notifications
  validate :job_flags_are_known
  validate :active_character_must_be_own

  # Logs in by player name, ignoring capitals.
  def self.log_in(name, password)
    authenticate_by(username: name.to_s.strip.downcase, password: password.to_s)
  end

  # Makes the given character active and remembers it for the room it is in.
  def switch_to(character)
    update!(active_character: character)
    remember_character(character, character.room)
  end

  # Remembers that this character was last used in the given place (a room or scene).
  def remember_character(character, context)
    remembered_characters.find_or_initialize_by(context: context).update!(character: character)
  end

  def remembered_character_for(context)
    remembered_characters.find_by(context: context)&.character
  end

  def wants_email?
    email.present? && email_notifications != "off"
  end

  # With "only when it's my turn", a scene of three or more players with a
  # turn order only emails this player when their turn comes up.
  def only_turn_emails_for?(scene)
    email_only_my_turn? && scene.turn_based? && scene.participants.size > 2
  end

  # Messages conversations with something new in them.
  def unread_conversations_count
    conversation_members.active.joins(:conversation)
      .where("conversations.last_message_at > COALESCE(conversation_members.last_read_at, '-infinity')").count
  end

  # Updates the Messages count in the header on this player's open pages.
  def broadcast_message_count
    Turbo::StreamsChannel.broadcast_replace_later_to [ self, :chapters ], target: "message_count",
      partial: "conversations/count", locals: { account: self }
  end

  # Seen on the site in the last few minutes.
  def online?
    last_seen_at.present? && last_seen_at > 10.minutes.ago
  end

  # May take the storyteller role in a scene: the Storyteller flag, or staff.
  def may_storytell?
    storyteller? || staff?
  end

  # Reloads this player's Chapter tabs on whatever page they have open.
  def broadcast_chapter_tabs
    Turbo::StreamsChannel.broadcast_replace_later_to [ self, :chapters ], target: "chapter_tabs", partial: "chapter_tabs/frame"
  end

  # --- Staff -----------------------------------------------------------------

  def staff?
    !player?
  end

  def staff_rank
    STAFF_LEVELS.fetch(staff_level.to_sym)
  end

  # Whether this account may do one of the admin jobs. Scribes and Wellkeepers
  # can do every job; Pages only the jobs they've been given.
  def can?(job)
    case job
    when :build, :review_apps
      flag = job == :build ? "build" : "app"
      scribe? || wellkeeper? || (page? && job_flags.include?(flag))
    when :manage_staff, :handle_reports, :ban then scribe? || wellkeeper?
    when :delete_characters, :change_game_settings then wellkeeper?
    else false
    end
  end

  # Whether this account may change `other`'s staff level and flags at all.
  # Nobody edits themselves. You can edit people below you, and Founders can
  # also edit Wellkeepers who aren't Founders.
  def can_manage?(other)
    return false unless can?(:manage_staff) && other != self
    other.staff_rank < staff_rank || (founder? && !other.founder?)
  end

  # The staff levels this account may hand out. Only Founders can make
  # Wellkeepers; Wellkeepers can make Scribes; Scribes can make Pages.
  def assignable_staff_levels
    return [] unless can?(:manage_staff)
    STAFF_LEVELS.keys.select do |level|
      rank = STAFF_LEVELS[level]
      rank < staff_rank || (level == :wellkeeper && founder?)
    end
  end

  private
    def player_name_is_free
      return if username.blank?
      taken = Account.where(username: username).where.not(id: id).exists?
      errors.add(:display_name, "is already taken") if taken
    end

    def email_needed_for_notifications
      if email_notifications != "off" && email.blank?
        errors.add(:email, "is needed to get email notifications")
      end
    end

    def job_flags_are_known
      unknown = job_flags - JOB_FLAGS
      errors.add(:job_flags, "include unknown jobs: #{unknown.join(", ")}") if unknown.any?
    end

    def active_character_must_be_own
      if active_character && active_character.account_id != id
        errors.add(:active_character, "must be one of your own characters")
      end
    end
end
