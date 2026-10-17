# An event on the calendar: something happening at a Place at a set time,
# such as a ball, a market day or a council. Players host them as one of
# their characters; characters sign up. When the time comes, a Chapter
# opens at the Place with the host in it, and everyone signed up gets an
# alert to join.
class Event < ApplicationRecord
  TITLE_LENGTH = 80
  DESCRIPTION_LENGTH = 2_000
  # How long a finished or cancelled event stays on the calendar.
  SHOWN_AFTER = 14.days

  belongs_to :room
  belongs_to :host, class_name: "Character", optional: true
  belongs_to :created_by, class_name: "Account", optional: true
  belongs_to :scene, optional: true
  has_many :signups, class_name: "EventSignup", dependent: :delete_all
  has_many :characters, through: :signups

  normalizes :title, with: ->(t) { t.squish }
  normalizes :description, with: ->(d) { d.strip.presence }
  validates :title, presence: true, length: { maximum: TITLE_LENGTH }
  validates :description, length: { maximum: DESCRIPTION_LENGTH }
  validates :starts_at, presence: true
  validate :starts_in_the_future, if: -> { will_save_change_to_starts_at? && !opened? }

  scope :live, -> { where(cancelled_at: nil) }
  scope :upcoming, -> { live.where(opened_at: nil).order(:starts_at) }
  scope :recent, -> { where(starts_at: SHOWN_AFTER.ago..).where("opened_at IS NOT NULL OR cancelled_at IS NOT NULL").order(starts_at: :desc) }
  scope :due, -> { upcoming.where(starts_at: ..Time.current) }

  # Staff who build the world can change or cancel any event.
  def self.staff?(account)
    account&.can?(:build) || false
  end

  # Opens a Chapter for every event whose time has come. Run every few
  # minutes, and whenever someone looks at the calendar.
  def self.open_due!
    due.find_each(&:open!)
  end

  def opened?
    opened_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  def changeable_by?(account)
    return false unless account
    self.class.staff?(account) || (host&.account_id == account.id) || (host.nil? && created_by_id == account.id)
  end

  # Whether characters can still sign up or drop out.
  def open_for_signups?
    !opened? && !cancelled?
  end

  # The characters of an account that could sign up: approved and played.
  def signup_choices_for(account)
    return [] unless account
    taken = signups.pluck(:character_id)
    account.characters.active.order(:name).select(&:can_play?).reject { |character| character.id.in?(taken) }
  end

  def cancel!
    update!(cancelled_at: Time.current)
  end

  # Opens the event's Chapter at its Place. The host goes in first (as its
  # Storyteller when allowed to run Chapters); if the host can't play, the
  # first character signed up who can. Everyone signed up is alerted.
  def open!
    with_lock do
      return if opened? || cancelled?
      people = [ host, *signups.includes(character: :account).order(:created_at).map(&:character) ].compact.uniq
      first = people.find(&:can_play?)
      chapter = start_chapter!(first) if first
      update!(opened_at: Time.current, scene: chapter)
      people.map(&:account).uniq.each do |account|
        Alert.notify!(account, "event", event: self, scene: chapter)
      end
    end
  end

  private
    def start_chapter!(character)
      settings = GameSetting.current
      chapter = Scene.create!(room: room, title: title, visibility: "joinable",
        auto_skip: settings.auto_skip, turn_minutes: settings.turn_minutes,
        summary: description&.first(Scene::StorySoFar::SUMMARY_LENGTH))
      chapter.participants.create!(character: character, position: 1,
        role: character.id == host_id && character.account.may_storytell? ? "storyteller" : "player")
      chapter
    end

    def starts_in_the_future
      errors.add(:starts_at, "must be in the future") if starts_at && starts_at <= Time.current
    end
end
