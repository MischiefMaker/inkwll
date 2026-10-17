# A stretch of roleplay set in one room, shown to players as a Chapter.
# Characters join it and write poses (Passages). Many scenes can run in the
# same room at once.
class Scene < ApplicationRecord
  include Turns
  include AsksForHelp

  # Players can undo finishing a scene for this long.
  UNDO_FINISH_WITHIN = 24.hours
  # How many of the latest posts an open Chapter's live page shows. The rest
  # are a click away, on a page that doesn't update by itself.
  LIVE_PASSAGES = 50

  belongs_to :room
  belongs_to :finished_by, class_name: "Character", optional: true
  has_many :reports, dependent: :destroy
  has_many :participants, -> { order(:position) }, class_name: "SceneParticipant", dependent: :destroy, inverse_of: :scene
  has_many :characters, through: :participants
  has_many :invitations, class_name: "SceneInvitation", dependent: :destroy
  has_many :inkling_links, class_name: "InklingSceneLink", dependent: :delete_all
  has_many :poses, -> { order(:sequence) }, dependent: :destroy, inverse_of: :scene
  has_many :pending_rolls, class_name: "Soul::PendingRoll", dependent: :delete_all
  has_many :award_suggestions, class_name: "Soul::AwardSuggestion", dependent: :delete_all

  # joinable: anyone can watch and join. private: others can see it exists and
  # who is in it, but need an invitation to read or join. hidden: only its
  # characters and invited characters know it exists.
  enum :visibility, { joinable: "joinable", private: "private", hidden: "hidden" }, prefix: true, validate: true

  normalizes :title, with: ->(t) { t.squish }
  validates :title, presence: true, length: { maximum: 100 }
  normalizes :subtitle, with: ->(s) { s.squish.presence }
  validates :subtitle, length: { maximum: 150 }
  # The Chapter's own in-character date. It starts as the game's date and
  # only moves when one of its players changes it.
  normalizes :ic_time, with: ->(t) { t.squish.presence }
  validates :ic_time, length: { maximum: 40 }
  before_create { self.ic_date ||= IcClock.today }
  # A permanent number, shown as "Chapter 12", one more than the newest.
  before_create { self.number ||= (Scene.maximum(:number) || 0) + 1 }
  # Only labels staff have defined.
  before_validation { self.label_ids = SceneLabel.where(id: Array(label_ids).compact_blank).ordered.pluck(:id) if label_ids_changed? }
  validates :turn_minutes, numericality: { only_integer: true, in: 1..120 }
  validate :hidden_stays_hidden_without_agreement, on: :update

  after_update_commit :broadcast_change

  # Scenes the account may know about: everything except hidden scenes it has
  # no character in and no invitation to. Hidden scenes made public by their
  # players, and reported scenes for staff who handle reports, count too.
  scope :visible_to, ->(account) {
    return where.not(visibility: :hidden).or(where.not(made_public_at: nil)) unless account
    visible = where.not(visibility: :hidden).or(where(id: involving(account).select(:id))).or(where.not(made_public_at: nil))
    account.can?(:handle_reports) ? visible.or(where(id: Report.select(:scene_id))).or(where.not(ruling_wanted_at: nil)) : visible
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
        role: (storyteller || character.gm?) && character.account.may_storytell? ? "storyteller" : "player")
      scene
    end
  end

  # Changing the date or time of day, with a line in the Chapter saying so.
  def change_ic_date!(by:, date:, time:)
    date = date.is_a?(Date) ? date : (Date.iso8601(date.to_s, Date::GREGORIAN) rescue nil)
    transaction do
      self.ic_date = date if date
      self.ic_time = time
      next true unless ic_date_changed? || ic_time_changed?
      save!
      add_system_line!("#{by.name} moved the #{Term[:scene].downcase} to #{ic_when}.")
      true
    end
  end

  # "October 14, 1526, late evening"
  def ic_when
    [ ic_date&.to_fs(:long), ic_time ].compact.join(", ")
  end

  # Whether a post is old enough to be only on the whole-Chapter page.
  def before_live_page?(pose)
    !finished? && pose.sequence <= last_sequence - LIVE_PASSAGES
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

  # Visibilities from most open to most closed. Players can always make a
  # scene more closed; opening it up needs everyone's agreement.
  OPENNESS = %w[ joinable private hidden ].freeze

  def closed_to_others?
    visibility_hidden? || visibility_private?
  end

  # Whether one player alone may switch the scene to this visibility.
  def may_switch_to?(visibility, from: self.visibility)
    made_public_at.present? || OPENNESS.index(visibility.to_s).to_i >= OPENNESS.index(from.to_s).to_i
  end

  def participant_for(character)
    participants.find { |p| p.character_id == character&.id }
  end

  def participants_for(account)
    participants.select { |p| p.character.account_id == account.id }
  end

  def participating?(account)
    account.present? && participants_for(account).any?
  end

  def invited?(character)
    invitations.any? { |i| i.character_id == character&.id }
  end

  def invited_account?(account)
    account.present? && invitations.any? { |i| i.character.account_id == account.id }
  end

  # Whether the account knows this scene exists.
  def visible_to?(account)
    !visibility_hidden? || made_public_at.present? || participating?(account) || invited_account?(account) || reported_to?(account) || ruling_asked_of?(account)
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
    participating?(account) || invited_account?(account) || reported_to?(account) || ruling_asked_of?(account)
  end

  # Staff can read a private or hidden scene only once someone reports it.
  def reported_to?(account)
    account.present? && account.can?(:handle_reports) && reports.exists?
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
      ActiveRecord.after_all_transactions_commit { Notifier.chapter_finished(self, by: by) }
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
      participants.update_all(tab_closed: false)
      add_system_line!("#{by.name} reopened this #{Term[:scene]}.")
      true
    end
  end

  # A hidden or private scene becomes public only when every player agrees.
  def consent_to_public!(participant, agree: true)
    with_lock do
      next false unless closed_to_others? && made_public_at.nil?

      participant.update!(public_consent_at: agree ? Time.current : nil)
      update!(made_public_at: Time.current) if participants.reload.all?(&:public_consent_at)
      true
    end
  end

  def join!(character)
    raise ArgumentError, "#{character.name} #{NOT_APPROVED}." unless character.can_play?
    raise ArgumentError, "#{character.name} can't join this #{Term[:scene]}." unless can_join?(character)

    with_lock do
      participants.create!(character: character, position: participants.maximum(:position).to_i + 1,
        role: character.gm? ? "storyteller" : "player")
      invitations.where(character: character).delete_all
      add_system_line!("#{character.name} joins the #{Term[:scene]}.")
    end
  end

  def leave!(character)
    participant = participant_for(character) or return
    raise ArgumentError, "This #{Term[:scene]} is finished." if finished?

    with_lock do
      # Pass the turn on, but never back to the one leaving.
      if current_turn_participant_id == participant.id
        following = next_participant_after(participant)
        give_turn_to!(following == participant ? nil : following)
      end
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
  # Banes they chose, and any extras (such as item features) too.
  def roll!(character, skill, difficulty_name, bnbs: nil, extras: nil, storyteller: nil)
    check_can_roll!(character)
    roll = character.roll_skill(skill, difficulty_name, bnbs: bnbs, extras: extras, storyteller: storyteller)
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

  # Casting a learned spell (Grimoire): a SOUL roll of the branch's Skill
  # against the spell's difficulty, posted like any other roll.
  def cast!(character, spell)
    raise ArgumentError, "Magic is switched off in this game." unless Grimoire.enabled?
    raise ArgumentError, "#{character.name} hasn't learned #{spell.name}." unless character.knows_spell?(spell)
    check_can_roll!(character)
    skill = spell.branch.skill
    roll = character.roll_skill(skill, spell.difficulty_name)
    with_lock do
      resume!(by: character) if paused?
      text = "#{character.name} casts #{spell.name} (#{skill.name} against #{spell.difficulty_name.humanize}, #{roll.difficulty})" \
        "#{" with #{roll.applied_text}" if roll.applied.any?} and gets #{roll.result}. " \
        "#{"Extraordinary! " if roll.extraordinary?}#{roll.degree_text}"
      pose = add_pose!(character: character, kind: "roll", body: text)
      roll.update!(scene: self, pose: pose)
      pose
    end
  rescue Character::SoulSheet::SheetError => e
    raise ArgumentError, e.message
  end

  # The Storyteller rolls for someone who has no sheet, such as an NPC: two
  # d20s plus the rating they choose, against a difficulty, posted like any roll.
  def npc_roll!(storyteller_character, npc_name:, rating:, difficulty_name:)
    raise ArgumentError, "Rolls are switched off in this game." unless Soul.enabled?
    participant = participant_for(storyteller_character)
    raise ArgumentError, "Only the #{Term[:storyteller]} can do that." unless participant&.storyteller?
    raise ArgumentError, "This #{Term[:scene]} is #{finished? ? "finished" : "locked by staff"}." unless writable?
    name = npc_name.to_s.squish
    raise ArgumentError, "Say who is rolling." if name.blank? || name.length > 60
    rating = Integer(rating.to_s, 10) rescue raise(ArgumentError, "The rating must be a number.")
    raise ArgumentError, "The rating must be between 0 and 30." unless (0..30).cover?(rating)
    difficulty = Soul::Rules.difficulties.fetch(difficulty_name.to_s) { raise ArgumentError, "Pick a difficulty." }
    dice = Soul::Dice.roll(0)
    result = dice[:total] + rating
    degree = Soul::Rules.degree_for(result - difficulty)
    with_lock do
      resume!(by: storyteller_character) if paused?
      add_pose!(character: storyteller_character, kind: "roll", body: "#{name} (NPC, rolled by #{storyteller_character.name}) rolls against " \
        "#{difficulty_name.to_s.humanize} (#{difficulty}) with a rating of #{rating} and gets #{result}. #{Soul::Rules::DEGREE_TEXT.fetch(degree, degree.humanize)}")
    end
  end

  # Asks the Chapter's Storyteller to judge a roll: they set the difficulty
  # and choose which Boons and Banes count.
  def ask_storyteller_to_roll!(character, skill, difficulty_name)
    check_can_roll!(character)
    raise ArgumentError, "This #{Term[:scene]} has no Storyteller to ask." unless storyteller_for(character)
    raise ArgumentError, "#{character.name} is already waiting on a roll here." if pending_rolls.in_progress.exists?(character: character)

    pending = pending_rolls.create!(character: character, skill: skill, difficulty_name: difficulty_name.to_s)
    add_system_line!("#{character.name} asks the #{Term[:storyteller]} for a #{skill.name} roll.")
    pending
  end

  # The Storyteller calls for a roll from a player. It waits like an asked-for
  # roll but already carries the Storyteller's ruling on each Boon and Bane, so
  # it rolls at once unless the player has some to choose.
  def call_roll!(character, skill, difficulty_name, by:, mandatory_ids: [], optional_ids: [], mandatory_extra_keys: [], optional_extra_keys: [])
    raise ArgumentError, "Only the #{Term[:storyteller]} can do that." unless participant_for(by)&.storyteller?
    raise ArgumentError, "#{character.name} isn't in this #{Term[:scene]}." unless participant_for(character)
    raise ArgumentError, "A #{Term[:storyteller]} doesn't judge their own player's rolls." if character.account_id == by.account_id
    check_can_roll!(character)
    raise ArgumentError, "#{character.name} is already waiting on a roll here." if pending_rolls.in_progress.exists?(character: character)

    transaction do
      pending = pending_rolls.create!(character: character, skill: skill, difficulty_name: difficulty_name.to_s, called: true)
      add_system_line!("The #{Term[:storyteller]} calls for a #{skill.name} roll from #{character.name}.")
      judge_roll!(pending, by: by, difficulty_name: difficulty_name, mandatory_ids: mandatory_ids, optional_ids: optional_ids,
        mandatory_extra_keys: mandatory_extra_keys, optional_extra_keys: optional_extra_keys)
      pending
    end
  end

  # The Storyteller rules on a waiting roll: the difficulty, which Boons and
  # Banes must count and which the player may choose. If nothing is left for
  # the player to choose, it is rolled straight away; otherwise the roll is
  # ready for the player.
  def judge_roll!(pending, by:, difficulty_name:, mandatory_ids: [], optional_ids: [], mandatory_extra_keys: [], optional_extra_keys: [])
    participant = participant_for(by)
    raise ArgumentError, "Only the #{Term[:storyteller]} can do that." unless participant&.storyteller?
    raise ArgumentError, "That roll has already been dealt with." unless pending.waiting?

    entries = pending.character.active_bnbs.to_a
    mandatory = Array(mandatory_ids).map(&:to_i) & entries.map(&:id)
    optional = (Array(optional_ids).map(&:to_i) & entries.map(&:id)) - mandatory
    extra_keys = pending.character.roll_extras.map(&:key)
    mandatory_extras = Array(mandatory_extra_keys).map(&:to_s) & extra_keys
    optional_extras = (Array(optional_extra_keys).map(&:to_s) & extra_keys) - mandatory_extras
    Soul::Rules.difficulties.fetch(difficulty_name.to_s) { raise ArgumentError, "Pick a difficulty." }
    if optional.empty? && optional_extras.empty?
      chosen = entries.select { |entry| mandatory.include?(entry.id) }
      extras = pending.character.roll_extras_for_keys(mandatory_extras)
      pose = roll!(pending.character, pending.skill, difficulty_name, bnbs: chosen, extras: extras, storyteller: by)
      pending.rolled!
      return pose
    end

    pending.update!(status: "ready", difficulty_name: difficulty_name.to_s, mandatory_bnb_ids: mandatory, optional_bnb_ids: optional,
      mandatory_extra_keys: mandatory_extras, optional_extra_keys: optional_extras, judge: by)
    add_system_line!("The #{Term[:storyteller]} has set the difficulty for #{pending.character.name}'s #{pending.skill.name} roll. Waiting for #{pending.character.name} to choose from the Boons and Banes offered.")
    broadcast_change
    nil
  end

  # The player confirms a ready roll: the required Boons and Banes plus any of
  # the optional ones they chose, then it rolls.
  def finish_roll!(pending, bnb_ids:, extra_keys: [])
    raise ArgumentError, "That roll isn't ready." unless pending.ready?

    chosen_ids = pending.mandatory_bnb_ids + (pending.optional_bnb_ids & Array(bnb_ids).map(&:to_i))
    chosen = pending.character.active_bnbs.select { |entry| chosen_ids.include?(entry.id) }
    extras = pending.character.roll_extras_for_keys(pending.mandatory_extra_keys + (pending.optional_extra_keys & Array(extra_keys).map(&:to_s)))
    pose = roll!(pending.character, pending.skill, pending.difficulty_name, bnbs: chosen, extras: extras, storyteller: pending.judge)
    pending.rolled!
    pose
  end

  def cancel_pending_roll!(pending)
    pending.cancelled! if pending.waiting? || pending.ready?
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

  # A line the game writes for a character, such as a payment or something
  # they crafted. It reads like a roll: part of the story, can't be edited,
  # and doesn't take a turn.
  def add_game_line!(character, body)
    add_pose!(character: character, kind: "roll", body: body)
  end

  # Re-renders this scene for everyone watching it, its room's list of scenes,
  # and the Chapter tabs of every player in it.
  def broadcast_change
    broadcast_refresh_later
    room.broadcast_refresh_later
    participants.includes(character: :account).map { |p| p.character.account }.uniq.each(&:broadcast_chapter_tabs)
  end

  private
    # One player alone can't open up a Hidden or Private scene: it becomes
    # public only when every player agrees (consent_to_public!). Making it
    # more closed is fine.
    def hidden_stays_hidden_without_agreement
      if visibility_changed? && !may_switch_to?(visibility, from: visibility_was)
        errors.add(:visibility, "can't be opened up from #{visibility_was.humanize} unless every player agrees to make it public")
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
