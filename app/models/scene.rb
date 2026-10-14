# A stretch of roleplay set in one room, shown to players as a Chapter.
# Characters join it and write poses (Passages). Many scenes can run in the
# same room at once.
class Scene < ApplicationRecord
  include Turns

  # A scene with no new pose for this long counts as idle: it drops down its
  # room's list but stays open. (Becomes a game setting with finishing, step 3.)
  IDLE_AFTER = 7.days

  belongs_to :room
  has_many :participants, -> { order(:position) }, class_name: "SceneParticipant", dependent: :destroy, inverse_of: :scene
  has_many :characters, through: :participants
  has_many :invitations, class_name: "SceneInvitation", dependent: :destroy
  has_many :poses, -> { order(:sequence) }, dependent: :destroy, inverse_of: :scene

  # joinable: anyone can watch and join. private: others can see it exists and
  # who is in it, but need an invitation to read or join. hidden: only its
  # characters and invited characters know it exists.
  enum :visibility, { joinable: "joinable", private: "private", hidden: "hidden" }, prefix: true, validate: true

  normalizes :title, with: ->(t) { t.squish }
  validates :title, presence: true, length: { maximum: 100 }
  validates :turn_minutes, numericality: { only_integer: true, in: 1..120 }

  after_update_commit :broadcast_change

  # Scenes the account may know about: everything except hidden scenes it has
  # no character in and no invitation to.
  scope :visible_to, ->(account) {
    where.not(visibility: :hidden).or(where(id: involving(account).select(:id)))
  }
  # Scenes the account has a character in, or an invitation to.
  scope :involving, ->(account) {
    characters = account.characters.select(:id)
    where(id: SceneParticipant.where(character_id: characters).select(:scene_id))
      .or(where(id: SceneInvitation.where(character_id: characters).select(:scene_id)))
  }
  scope :by_activity, -> { order(Arel.sql("COALESCE(scenes.last_pose_at, scenes.created_at) DESC")) }

  # Starts a new scene in the room the character is standing in.
  def self.start!(character:, storyteller: false, **attributes)
    settings = GameSetting.current
    transaction do
      scene = create!(room: character.room, auto_skip: settings.auto_skip, turn_minutes: settings.turn_minutes, **attributes)
      scene.participants.create!(character: character, position: 1,
        role: storyteller && character.account.may_storytell? ? "storyteller" : "player")
      scene
    end
  end

  def last_activity_at
    last_pose_at || created_at
  end

  def idle?
    last_activity_at < IDLE_AFTER.ago
  end

  def participant_for(character)
    participants.find { |p| p.character_id == character&.id }
  end

  def participants_for(account)
    participants.select { |p| p.character.account_id == account.id }
  end

  def participating?(account)
    participants_for(account).any?
  end

  def invited?(character)
    invitations.any? { |i| i.character_id == character&.id }
  end

  def invited_account?(account)
    invitations.any? { |i| i.character.account_id == account.id }
  end

  # Whether the account knows this scene exists.
  def visible_to?(account)
    !visibility_hidden? || participating?(account) || invited_account?(account)
  end

  # Whether the account can read the scene's poses. Joinable scenes can be
  # watched by anyone; private and hidden ones only by their characters and
  # invited characters.
  def readable_by?(account)
    visibility_joinable? || participating?(account) || invited_account?(account)
  end

  def can_join?(character)
    character.present? && participant_for(character).nil? && (visibility_joinable? || invited?(character))
  end

  def join!(character)
    raise ArgumentError, "#{character.name} can't join this #{Term[:scene]}." unless can_join?(character)

    with_lock do
      participants.create!(character: character, position: participants.maximum(:position).to_i + 1)
      invitations.where(character: character).delete_all
      add_system_line!("#{character.name} joins the #{Term[:scene]}.")
    end
  end

  def leave!(character)
    participant = participant_for(character) or return

    with_lock do
      advance_turn! if current_turn_participant_id == participant.id
      participant.destroy!
      participants.reset
      add_system_line!("#{character.name} leaves the #{Term[:scene]}.")
      check_turn_still_valid!
    end
  end

  # Posts a pose by one of the scene's characters. The server numbers every
  # pose, so the order never depends on whose browser was faster.
  def post!(character, body)
    participant = participant_for(character) or raise ArgumentError, "#{character.name} isn't in this #{Term[:scene]}."

    with_lock do
      if (waiting = poses_to_wait_for(participant)).positive?
        raise ArgumentError, "Wait for #{waiting} more #{Term[:pose, count: waiting]} before posting again (the 3-#{Term[:pose]} rule)."
      end

      pose = add_pose!(character: character, kind: "passage", body: body)
      after_pose_by(participant)
      pose
    end
  end

  # A line from the game itself, such as "Wren joins the Chapter."
  def add_system_line!(body)
    add_pose!(character: nil, kind: "system", body: body)
  end

  # Re-renders this scene for everyone watching it, its room's list of scenes,
  # and the Chapter tabs of every player in it.
  def broadcast_change
    broadcast_refresh_later
    room.broadcast_refresh_later
    participants.includes(character: :account).map { |p| p.character.account }.uniq.each(&:broadcast_chapter_tabs)
  end

  private
    # Locks the scene while numbering, so two poses can never get the same number.
    def add_pose!(**attributes)
      with_lock do
        increment!(:last_sequence, touch: false)
        update_columns(last_pose_at: Time.current) if attributes[:kind] == "passage"
        poses.create!(sequence: last_sequence, **attributes)
      end
    end
end
