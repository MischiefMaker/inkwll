# A stretch of roleplay set in one room, shown to players as a Chapter.
# Characters join it and write poses (Passages). Many scenes can run in the
# same room at once.
class Scene < ApplicationRecord
  include Turns

  # Players can undo finishing a scene for this long.
  UNDO_FINISH_WITHIN = 24.hours

  belongs_to :room
  belongs_to :finished_by, class_name: "Character", optional: true
  has_many :reports, dependent: :destroy
  has_many :participants, -> { order(:position) }, class_name: "SceneParticipant", dependent: :destroy, inverse_of: :scene
  has_many :characters, through: :participants
  has_many :invitations, class_name: "SceneInvitation", dependent: :destroy
  has_many :poses, -> { order(:sequence) }, dependent: :destroy, inverse_of: :scene
  has_many :pending_rolls, class_name: "Soul::PendingRoll", dependent: :delete_all

  # joinable: anyone can watch and join. private: others can see it exists and
  # who is in it, but need an invitation to read or join. hidden: only its
  # characters and invited characters know it exists.
  enum :visibility, { joinable: "joinable", private: "private", hidden: "hidden" }, prefix: true, validate: true

  normalizes :title, with: ->(t) { t.squish }
  validates :title, presence: true, length: { maximum: 100 }
  validates :turn_minutes, numericality: { only_integer: true, in: 1..120 }
  validate :hidden_stays_hidden_without_agreement, on: :update

  after_update_commit :broadcast_change

  # Scenes the account may know about: everything except hidden scenes it has
  # no character in and no invitation to. Hidden scenes made public by their
  # players, and reported scenes for staff who handle reports, count too.
  scope :visible_to, ->(account) {
    visible = where.not(visibility: :hidden).or(where(id: involving(account).select(:id))).or(where.not(made_public_at: nil))
    account.can?(:handle_reports) ? visible.or(where(id: Report.select(:scene_id))) : visible
  }
  # Scenes the account has a character in, or an invitation to.
  scope :involving, ->(account) {
    characters = account.characters.select(:id)
    where(id: SceneParticipant.where(character_id: characters).select(:scene_id))
      .or(where(id: SceneInvitation.where(character_id: characters).select(:scene_id)))
  }
  scope :open, -> { where(finished_at: nil) }
  scope :finished, -> { where.not(finished_at: nil) }
  # Open scenes that aren't idle.
  scope :active, -> { open.where("COALESCE(scenes.last_pose_at, scenes.created_at) >= ?", idle_after.ago) }
  # Open scenes nobody has posted in for the game's auto-finish time.
  # Paused scenes are never abandoned.
  scope :abandoned, -> { open.where(paused_at: nil).where("COALESCE(scenes.last_pose_at, scenes.created_at) < ?", GameSetting.current.auto_finish_days.days.ago) }
  scope :by_activity, -> { order(Arel.sql("COALESCE(scenes.last_pose_at, scenes.created_at) DESC")) }

  # Starts a new scene in the room the character is standing in.
  NOT_APPROVED = "needs staff approval before joining #{Term[:scene, count: 2].downcase}".freeze

  def self.start!(character:, storyteller: false, **attributes)
    raise ArgumentError, "#{character.name} #{NOT_APPROVED}." unless character.can_play?
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

  # A scene with no new pose for the game's idle time drops down its room's
  # list but stays open; a new pose wakes it.
  def self.idle_after
    GameSetting.current.idle_days.days
  end

  def idle?
    !finished? && last_activity_at < Scene.idle_after.ago
  end

  def finished?
    finished_at.present?
  end

  def locked?
    locked_at.present?
  end

  # Whether poses can still be posted, edited or removed.
  def writable?
    !finished? && !locked?
  end

  def paused?
    paused_at.present?
  end

  # Players can pause a scene to pick it up another day, with an optional
  # note such as "Back Saturday". The turn timer stops and the game won't
  # finish it while it's paused. A new Passage picks it back up.
  def pause!(by:, note: nil)
    with_lock do
      next false if paused? || !writable?
      note = note.to_s.squish.first(100).presence
      update!(paused_at: Time.current, pause_note: note, turn_token: turn_token + 1)
      add_system_line!("#{by.name} paused this #{Term[:scene]}#{": #{note}" if note}.")
      true
    end
  end

  def resume!(by:)
    with_lock do
      next false unless paused?
      update!(paused_at: nil, pause_note: nil, turn_started_at: current_turn_participant && Time.current, turn_warned_at: nil)
      add_system_line!("#{by.name} picked this #{Term[:scene]} back up.")
      schedule_turn_timer
      true
    end
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
    !visibility_hidden? || made_public_at.present? || participating?(account) || invited_account?(account) || reported_to?(account)
  end

  # Whether the account can read the scene's poses.
  # - Joinable scenes can be watched by anyone.
  # - Private scenes, while open, only by their characters and invited
  #   characters. Once finished, their Manuscript is public.
  # - Hidden scenes only by their characters (and invited ones), unless every
  #   player agreed to make the finished Manuscript public.
  # - Staff who handle reports can read a scene once it has been reported.
  def readable_by?(account)
    return true if visibility_joinable? || made_public_at.present? || (visibility_private? && finished?)
    participating?(account) || invited_account?(account) || reported_to?(account)
  end

  # Staff can read a private or hidden scene only once someone reports it.
  def reported_to?(account)
    account.can?(:handle_reports) && reports.exists?
  end

  def can_join?(character)
    character.present? && !finished? && participant_for(character).nil? && (visibility_joinable? || invited?(character))
  end

  # Finishing locks the poses and files the scene in the Archives as a
  # Manuscript. The other players can undo it for UNDO_FINISH_WITHIN.
  # With no character, the game finished it after the auto-finish time.
  def finish!(by: nil)
    with_lock do
      next false if finished?

      add_system_line!(by ? "#{by.name} finished this #{Term[:scene]}." :
        "This #{Term[:scene]} was finished after #{GameSetting.current.auto_finish_days} days without a new #{Term[:pose]}.")
      update!(finished_at: Time.current, finished_by: by, current_turn_participant: nil,
        turn_started_at: nil, turn_warned_at: nil, turn_token: turn_token + 1)
      ActiveRecord.after_all_transactions_commit { award_xp! }
      true
    end
  end

  def can_undo_finish?
    finished? && finished_at > UNDO_FINISH_WITHIN.ago
  end

  def reopen!(by:)
    with_lock do
      next false unless can_undo_finish? && participant_for(by)

      update!(finished_at: nil, finished_by: nil)
      add_system_line!("#{by.name} reopened this #{Term[:scene]}.")
      true
    end
  end

  # A finished hidden scene becomes public only when every player agrees.
  def consent_to_public!(participant, agree: true)
    with_lock do
      next false unless visibility_hidden? && made_public_at.nil?

      participant.update!(public_consent_at: agree ? Time.current : nil)
      update!(made_public_at: Time.current) if participants.reload.all?(&:public_consent_at)
      true
    end
  end

  def join!(character)
    raise ArgumentError, "#{character.name} #{NOT_APPROVED}." unless character.can_play?
    raise ArgumentError, "#{character.name} can't join this #{Term[:scene]}." unless can_join?(character)

    with_lock do
      participants.create!(character: character, position: participants.maximum(:position).to_i + 1)
      invitations.where(character: character).delete_all
      add_system_line!("#{character.name} joins the #{Term[:scene]}.")
    end
  end

  def leave!(character)
    participant = participant_for(character) or return
    raise ArgumentError, "This #{Term[:scene]} is finished." if finished?

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
  # kind is "passage", "npc" (with npc_name), "narration" or "ooc"; see Pose.
  def post!(character, body, kind: "passage", npc_name: nil)
    participant = participant_for(character) or raise ArgumentError, "#{character.name} isn't in this #{Term[:scene]}."
    raise ArgumentError, "#{character.name} #{NOT_APPROVED}." unless character.can_play?
    raise ArgumentError, "This #{Term[:scene]} is #{finished? ? "finished" : "locked by staff"}." unless writable?
    raise ArgumentError, "That kind of post isn't allowed here." unless postable_kinds(participant).include?(kind)

    with_lock do
      takes_turn = Pose::TURN_KINDS.include?(kind)
      if takes_turn && (waiting = poses_to_wait_for(participant)).positive?
        raise ArgumentError, "Wait for #{waiting} more #{Term[:pose, count: waiting]} before posting again (the 3-#{Term[:pose]} rule)."
      end

      resume!(by: character) if paused? && Pose::STORY_KINDS.include?(kind)
      pose = add_pose!(character: character, kind: kind, body: body, npc_name: (npc_name if kind == "npc"))
      after_pose_by(participant) if takes_turn
      pose
    end
  end

  # A SOUL roll: the game posts the result as a "roll" pose. It doesn't
  # take a turn. A Storyteller rolling for a player passes the Boons and
  # Banes they chose.
  def roll!(character, skill, difficulty_name, bnbs: nil, storyteller: nil)
    check_can_roll!(character)
    roll = character.roll_skill(skill, difficulty_name, bnbs: bnbs, storyteller: storyteller)
    with_lock do
      resume!(by: character) if paused?
      text = "#{character.name} rolls #{skill.name} against #{difficulty_name.to_s.humanize} (#{roll.difficulty})" \
        "#{" as judged by #{storyteller.name}" if storyteller}#{" with #{roll.applied_text}" if roll.applied.any?} and gets #{roll.result}. " \
        "#{"Extraordinary! " if roll.extraordinary?}#{roll.degree_text}"
      pose = add_pose!(character: character, kind: "roll", body: text)
      roll.update!(scene: self, pose: pose)
      pose
    end
  rescue Character::SoulSheet::SheetError => e
    raise ArgumentError, e.message
  end

  # Asks the Chapter's Storyteller to judge a roll: they set the difficulty
  # and choose which Boons and Banes count.
  def ask_storyteller_to_roll!(character, skill, difficulty_name)
    check_can_roll!(character)
    raise ArgumentError, "This #{Term[:scene]} has no Storyteller to ask." unless storyteller_for(character)
    raise ArgumentError, "#{character.name} is already waiting on a roll here." if pending_rolls.waiting.exists?(character: character)

    pending = pending_rolls.create!(character: character, skill: skill, difficulty_name: difficulty_name.to_s)
    add_system_line!("#{character.name} asks the #{Term[:storyteller]} for a #{skill.name} roll.")
    pending
  end

  # The Storyteller rolls a waiting roll.
  def judge_roll!(pending, by:, difficulty_name:, bnb_ids:)
    participant = participant_for(by)
    raise ArgumentError, "Only the #{Term[:storyteller]} can do that." unless participant&.storyteller?
    raise ArgumentError, "That roll has already been dealt with." unless pending.waiting?

    chosen = pending.character.active_bnbs.select { |entry| Array(bnb_ids).map(&:to_i).include?(entry.id) }
    pose = roll!(pending.character, pending.skill, difficulty_name, bnbs: chosen, storyteller: by)
    pending.rolled!
    pose
  end

  def cancel_pending_roll!(pending)
    pending.cancelled! if pending.waiting?
    broadcast_change
  end

  # A Storyteller who can judge this character's rolls (not their own).
  def storyteller_for(character)
    participants.detect { |p| p.storyteller? && p.character.account_id != character.account_id }
  end

  # Finishing gives XP to each character who posted, once per Chapter.
  def award_xp!
    return unless Soul.enabled? && (amount = Soul::Rules.scene_award).positive?
    posted = poses.story.pluck(:character_id).uniq
    median = Character.median_xp_earned
    participants.includes(:character).map(&:character).each do |character|
      next unless posted.include?(character.id) && character.can_play?
      character.award_xp!(amount, source: "scene", key: "scene:#{id}:#{character.id}", catchup: true, median: median)
    end
  end

  # Checks a character may roll in this Chapter.
  def check_can_roll!(character)
    raise ArgumentError, "Rolls are switched off in this game." unless Soul.enabled?
    participant_for(character) or raise ArgumentError, "#{character.name} isn't in this #{Term[:scene]}."
    raise ArgumentError, "#{character.name} #{NOT_APPROVED}." unless character.can_play?
    raise ArgumentError, "This #{Term[:scene]} is #{finished? ? "finished" : "locked by staff"}." unless writable?
  end

  # What a participant may post. Narration is for the Storyteller, or for
  # anyone when the Chapter has none.
  def postable_kinds(participant)
    kinds = %w[ passage npc ooc ]
    kinds << "narration" if participant.storyteller? || participants.none?(&:storyteller?)
    kinds
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
    # One player alone can't open up a Hidden scene: it becomes public only
    # when every player agrees (consent_to_public!).
    def hidden_stays_hidden_without_agreement
      if visibility_changed? && visibility_was == "hidden" && made_public_at.nil?
        errors.add(:visibility, "can't change from Hidden unless every player agrees to make it public")
      end
    end

    # Locks the scene while numbering, so two poses can never get the same number.
    def add_pose!(**attributes)
      with_lock do
        increment!(:last_sequence, touch: false)
        update_columns(last_pose_at: Time.current) if Pose::STORY_KINDS.include?(attributes[:kind])
        poses.create!(sequence: last_sequence, **attributes)
      end
    end
end
