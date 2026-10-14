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
  def roster_requested? = roster_requested_at.present?

  # A player asking staff to put their character on the roster now.
  def request_roster!
    update!(roster_requested_at: Time.current)
  end

  def put_on_roster!(note: nil)
    transaction do
      old_account = account
      scene_participants.includes(:scene).each do |participant|
        participant.scene.leave!(self) unless participant.scene.finished?
      end
      scene_invitations.delete_all
      RememberedCharacter.where(character: self).delete_all
      old_account.update!(active_character: nil) if old_account.active_character_id == id
      update!(account: Account.roster_keeper, on_roster_at: Time.current, retired_at: Time.current,
        roster_requested_at: nil, roster_when_idle: false, roster_note: note.presence || roster_note)
    end
  end

  # Staff approved a roster application: the character changes hands. A
  # sheet staff never filled in stays open for the new player to finish.
  def take_over!(new_account)
    update!(account: new_account, on_roster_at: nil, retired_at: nil, roster_note: nil, status: "approved")
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

    # A pre-made or "wanted" character staff add straight to the roster.
    def create_for_roster!(name:, description: nil, roster_note: nil)
      character = Account.roster_keeper.characters.create!(name: name, description: description)
      character.update!(status: "approved", on_roster_at: Time.current, retired_at: Time.current, roster_note: roster_note)
      character
    end
  end
end
