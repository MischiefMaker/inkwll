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

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :remembered_characters, dependent: :delete_all
  has_many :ooc_messages, dependent: :destroy
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
    when :manage_staff then scribe? || wellkeeper?
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
