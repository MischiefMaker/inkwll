# The roster: characters other players can apply to take over.
#
# A character on the roster belongs to the built-in Roster account and is
# retired (nobody can play it) until staff approve someone's application.
# The new player gets everything in character: profile, private answers,
# SOUL sheet, Boons and Banes, relationships and gallery. Nothing out of
# character comes with it, and it leaves any unfinished Chapters when it
# goes on the roster.
module Character::Roster
  extend ActiveSupport::Concern

  included do
    has_many :roster_applications, dependent: :delete_all
    scope :on_roster, -> { where.not(on_roster_at: nil) }
  end

  def on_roster? = on_roster_at.present?

  # Kept by the Roster account: on the roster, or still being prepared.
  def roster_kept? = account_id.present? && account_id == Account.roster_keeper.id

  # A character staff added for the roster but haven't opened to applicants
  # yet, while they fill in the profile, SOUL and background (owner).
  def preparing_for_roster? = roster_kept? && !on_roster?

  def open_on_roster!
    update!(status: "approved", on_roster_at: Time.current)
  end
  def roster_requested? = roster_requested_at.present?

  # A player asking staff to put their character on the roster now.
  def request_roster!
    update!(roster_requested_at: Time.current)
  end

  def put_on_roster!(note: nil)
    transaction do
      old_account = account
      leave_open_scenes!
      scene_invitations.delete_all
      RememberedCharacter.where(character: self).delete_all
      old_account.update!(active_character: nil) if old_account.active_character_id == id
      update!(account: Account.roster_keeper, on_roster_at: Time.current, retired_at: Time.current,
        roster_requested_at: nil, roster_when_idle: false, roster_note: note.presence || roster_note)
    end
  end

  # Staff approved a roster application (or the player claimed it): the
  # character changes hands. The new player's answers to the game's roster
  # questions replace the old ones. If the game asks for the whole
  # application again, the character goes back to a draft for staff to
  # approve. A sheet staff never filled in stays open for the new player.
  def take_over!(new_account, answers: {})
    transaction do
      self.profile = RosterApplication.questions.to_h { |field| [ field.id.to_s, answers[field.id.to_s] ] }
      update!(account: new_account, on_roster_at: nil, retired_at: nil, roster_note: nil,
        status: GameSetting.current.roster_resubmit? ? "draft" : "approved")
    end
  end

  class_methods do
    # Characters whose players asked for it go back on the roster once they
    # haven't posted or moved for the game's idle time.
    def release_idle!(now = Time.current)
      days = GameSetting.current.roster_idle_days
      active.where(roster_when_idle: true, on_roster_at: nil)
        .where("COALESCE(last_active_at, created_at) < ?", now - days.days)
        .find_each(&:put_on_roster!)
    end

    # A pre-made or "wanted" character staff add for the roster. It stays
    # hidden from players until staff open it on the roster, so they can fill
    # in the profile, SOUL and background first (owner).
    def create_for_roster!(name:, description: nil, roster_note: nil)
      character = Account.roster_keeper.characters.create!(name: name, description: description)
      character.update!(retired_at: Time.current, roster_note: roster_note)
      character
    end
  end
end
