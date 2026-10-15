# A thread about one character: a goal, a secret, a request to staff, a hint
# from staff. Rebuilt from the owner's Inklings plugin for AresMUSH.
#
# The player builds it up in private (staff can't see a draft), shares it
# with other characters if they like, and submits it when they want staff
# to answer. Submitting locks it until staff approve this round or send it
# back for changes. A staff reply is never an approval, and never unlocks it.
# Approving a round isn't the end: the player can keep going and submit
# again. Closing is the real "nothing more to do".
class Inkling < ApplicationRecord
  include AffectsStaffQueue
  include Visibility
  include Outcomes

  REVIEW_STATES = %w[ draft submitted needs_changes approved ].freeze

  belongs_to :character
  belongs_to :creator, class_name: "Account"
  has_many :entries, -> { order(:sequence) }, class_name: "InklingEntry", dependent: :delete_all, inverse_of: :inkling
  has_many :shares, class_name: "InklingShare", dependent: :delete_all
  has_many :shared_characters, through: :shares, source: :character
  has_many :reads, class_name: "InklingRead", dependent: :delete_all

  enum :status, { open: "open", closed: "closed" }, validate: true
  enum :review_state, REVIEW_STATES.index_by(&:itself), validate: true

  normalizes :title, with: ->(t) { t.squish }
  validates :title, presence: true, length: { maximum: 120 }
  validates :kind, inclusion: { in: ->(_) { Inkling.types.keys } }

  scope :newest_first, -> { order(Arel.sql("COALESCE(inklings.last_entry_at, inklings.created_at) DESC")) }
  scope :staff_visible, -> { where.not(staff_visible_at: nil) }

  # --- Types ---------------------------------------------------------------

  def self.types
    @types ||= Rails.application.config_for(:inklings).as_json.fetch("types")
  end

  # The types this account can start: players start player and shared
  # types; staff can start any type, for any character.
  def self.types_for(account)
    staff = account.can?(:review_apps)
    types.select { |_, type| staff || type["category"] != "staff" }
  end

  def self.enabled?
    GameSetting.current.inklings_enabled?
  end

  def type_name = self.class.types.dig(kind, "name") || kind.humanize
  def locked? = submitted?
  def staff_made? = self.class.types.dig(kind, "category") == "staff" || creator_id != character.account_id

  # --- Writing -------------------------------------------------------------

  def self.start!(character:, by:, kind:, title:, body:)
    raise ArgumentError, "Pick a type." unless types_for(by).key?(kind.to_s)
    transaction do
      inkling = create!(character: character, creator: by, kind: kind, title: title,
        staff_visible_at: (Time.current if by != character.account))
      inkling.add_entry!(account: by, character: (character if by == character.account), body: body) if body.present?
      inkling
    end
  end

  # Adds an entry, numbered within the thread.
  # unless_locked: refuse if it was sent to staff in the meantime.
  def add_entry!(account:, body:, kind: "public", character: nil, private_to: nil, private: false, soul_roll: nil, unless_locked: false)
    with_lock do
      raise ArgumentError, "This is waiting for staff, so it's locked until they answer." if unless_locked && (locked? || closed?)
      entry = entries.create!(sequence: last_sequence + 1, account: account, character: character, kind: kind,
        body: body, private_to: private_to, private: private, soul_roll: soul_roll)
      update!(last_sequence: entry.sequence, last_entry_at: entry.created_at)
      mark_read!(account) if account
      ActiveRecord.after_all_transactions_commit { alert_about(entry) }
      entry
    end
  end

  def add_system_entry!(body)
    add_entry!(account: nil, kind: "system", body: body)
  end

  # --- Review --------------------------------------------------------------

  def submit!(by:)
    raise ArgumentError, "This Inkling is waiting for staff already." if submitted?
    raise ArgumentError, "This Inkling is closed." if closed?
    transaction do
      update!(review_state: "submitted", submitted_at: Time.current, staff_visible_at: staff_visible_at || Time.current)
      add_system_entry!("#{by.name} sent this to staff.")
    end
  end

  def approve!(by:)
    review!("approved", "Staff approved this. #{character.name} can carry on and send it again later.", by)
  end

  def request_changes!(by:, note:)
    transaction do
      review!("needs_changes", "Staff sent this back for changes.", by)
      add_entry!(account: by, kind: "public", body: note) if note.present?
    end
  end

  # who: how the line names the closer, a character's name or "Staff".
  def close!(who:)
    transaction do
      update!(status: "closed", review_state: (submitted? ? "approved" : review_state))
      add_system_entry!("#{who} closed this.")
    end
  end

  def reopen!
    transaction do
      update!(status: "open")
      add_system_entry!("Staff reopened this.")
    end
  end

  # --- Reading -------------------------------------------------------------

  def last_read_sequence_for(account)
    reads.find_by(account: account)&.last_read_sequence.to_i
  end

  def mark_read!(account)
    read = reads.find_or_initialize_by(account: account)
    read.update!(last_read_sequence: last_sequence) if read.last_read_sequence.to_i < last_sequence || read.new_record?
  end

  private
    def review!(state, line, by)
      raise ArgumentError, "This Inkling isn't waiting for staff." unless submitted?
      transaction do
        update!(review_state: state)
        add_system_entry!(line)
      end
      Alert.notify!(character.account, "inkling", inkling: self, character: character) unless character.account == by
    end

    # Tells the players who can see a new entry about it, one alert per
    # Inkling until they read it.
    def alert_about(entry)
      viewers = [ character.account, *shared_characters.includes(:account).map(&:account) ].uniq
      viewers.each do |account|
        next if account == entry.account || account.system? || !entry.visible_to?(account)
        Alert.notify!(account, "inkling", inkling: self, character: character)
      end
    end
end
