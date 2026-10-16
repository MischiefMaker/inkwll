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
  # A reset link staff make for a player with no email (Players and staff >
  # the player > Make a password reset link). It lasts a day, since staff have
  # to pass it on, and stops working once the password changes.
  generates_token_for(:staff_password_reset, expires_in: 1.day) { password_salt.last(10) }
  # The player's own picture, on their player profile and in the OOC Chat.
  has_one_attached :icon
  attribute :remove_icon, :boolean, default: false
  after_save { icon.purge_later if remove_icon && icon.attached? }
  # At least 10 characters, with a number, a capital and a lower-case letter.
  validates :password, length: { minimum: 10, maximum: 72 }, allow_nil: true
  validate :password_is_strong_enough
  has_many :sessions, dependent: :destroy
  # Characters outlive their account: an account with characters can't be
  # deleted (decided 2026-10-14; deleted accounts keep their characters).
  has_many :characters, dependent: :restrict_with_error
  has_many :remembered_characters, dependent: :delete_all
  has_many :saved_places, dependent: :delete_all
  has_many :conversation_members, dependent: :destroy
  has_many :ooc_messages, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :account_warnings, dependent: :destroy
  has_many :bans, dependent: :destroy
  has_many :roster_applications, dependent: :delete_all
  has_many :alerts, dependent: :delete_all
  belongs_to :active_character, class_name: "Character", optional: true

  enum :staff_level, STAFF_LEVELS, default: :player, validate: true

  include LogsNameChanges
  logs_name_changes :display_name

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
  validates :about_me, length: { maximum: 5_000 }
  validate :icon_is_a_reasonable_picture
  validate :email_needed_for_notifications
  validate :job_flags_are_known
  validate :active_character_must_be_own

  # Logs in by player name, ignoring capitals.
  # Archived accounts and the built-in Roster account can't log in.
  def self.log_in(name, password)
    account = authenticate_by(username: name.to_s.strip.downcase, password: password.to_s)
    account unless account.nil? || account.system? || account.archived?
  end

  # The built-in account that holds characters on the roster. Its name has
  # a space, which player names can't, so no player can ever take it.
  # The characters this account may edit: their own, and for staff who
  # review applications, the ones kept for the roster.
  def editable_characters
    can?(:review_apps) ? Character.where(account: [ self, Account.roster_keeper ]) : characters
  end

  def self.roster_keeper
    find_by(username: "the roster") || new(display_name: "The Roster", username: "the roster", system: true,
      password: SecureRandom.base58(24) + "Aa1").tap { |account| account.save!(validate: false) }
  end

  def archived? = archived_at.present?

  # Accounts are archived, not deleted. The player can't log in, and their
  # characters are retired, or go on the roster if they asked for that.
  def archive!
    transaction do
      characters.active.each { |character| character.roster_when_idle? ? character.put_on_roster! : character.retire! }
      sessions.destroy_all
      update!(archived_at: Time.current, active_character: nil)
    end
  end

  # Makes the given character active and remembers it for the room it is in.
  def switch_to(character)
    update!(active_character: character)
    remember_character(character, character.room)
  end

  # When a character stops being playable (retired, put on the roster), the
  # player carries on as their next character instead of as nobody.
  def step_away_from(character)
    return unless active_character_id == character.id
    update!(active_character: characters.active.where.not(id: character.id).order(:name).first)
  end

  # Remembers that this character was last used in the given place (a room or scene).
  def remember_character(character, context)
    remembered_characters.find_or_initialize_by(context: context).update!(character: character)
  end

  def remembered_character_for(context)
    remembered_characters.find_by(context: context)&.character
  end

  # Archived players are never emailed.
  def wants_email?
    email.present? && email_notifications != "off" && !archived?
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

  # The GM stand-in staff and Storytellers pick as "GM" under Playing as, to
  # post and run Chapters as their player. Made the first time it's needed,
  # named after the player, and kept out of every character list.
  def gm!
    gm = characters.find_by(gm: true)
    if gm
      gm.update!(name: gm_name) unless gm.name == gm_name
      return gm
    end
    characters.create!(gm: true, name: gm_name, status: "approved", room: active_character&.room || Room.starting)
  end

  # The character a switcher choice names: one of this player's own, or "gm"
  # (staff and Storytellers only). Anything else is not found.
  def character_for_choice(choice)
    if choice.to_s == "gm"
      raise ActiveRecord::RecordNotFound unless may_storytell?
      gm!
    else
      characters.active.find(choice)
    end
  end

  # The open Chapters where it's one of this player's characters' turn.
  def turns_waiting
    @turns_waiting ||= SceneParticipant.joins(:scene).where(character: characters)
      .where(scenes: { finished_at: nil, paused_at: nil }).includes(:scene)
      .select { |participant| participant.scene.turn_of?(participant) }
  end

  # The Chapter to open for the quill beside Settings: the first where it's
  # your turn in any of the given Settings.
  def turn_scene_in(room_ids)
    ids = Array(room_ids)
    turns_waiting.map(&:scene).find { |scene| ids.include?(scene.room_id) }
  end

  # The Chapter to open for the quill beside a character whose turn it is.
  def turn_scene_for(character)
    turns_waiting.find { |participant| participant.character_id == character.id }&.scene
  end

  def gm_name
    taken = Character.where.not(account_id: id).or(Character.where(account_id: id, gm: false)).where("lower(name) = ?", display_name.downcase).exists?
    taken ? "#{display_name} (GM)" : display_name
  end

  # Reloads this player's Chapter tabs on whatever page they have open.
  # The alerts bell in the header, replaced live when an alert arrives.
  def broadcast_alert_count
    Turbo::StreamsChannel.broadcast_replace_later_to [ self, :chapters ], target: "alert_count",
      partial: "alerts/count", locals: { account: self }
  end

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
    when :manage_staff, :handle_reports, :ban, :manage_forums then scribe? || wellkeeper?
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
    def password_is_strong_enough
      return if password.nil?
      missing = { /\d/ => "a number", /[A-Z]/ => "a capital letter", /[a-z]/ => "a lower-case letter" }.reject { |pattern, _| password.match?(pattern) }.values
      errors.add(:password, "needs #{missing.to_sentence}") if missing.any?
    end

    def player_name_is_free
      return if username.blank?
      taken = Account.where(username: username).where.not(id: id).exists?
      errors.add(:display_name, "is already taken") if taken
    end

    def icon_is_a_reasonable_picture
      return unless icon.attached? && attachment_changes["icon"]
      errors.add(:icon, "must be a picture (PNG, JPEG, GIF or WebP)") unless icon.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
      errors.add(:icon, "must be smaller than 5 MB") if icon.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
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
