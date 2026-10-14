# Who may pose next in a scene. The server alone decides whose turn it is.
#
# Pose modes:
# - turns (default): characters take turns in the order they joined. Posting
#   out of turn is allowed after a warning, and doesn't move the turn on.
# - free: anyone may pose at any time.
# - three_pose: a character must wait for three poses by others before posing
#   again. Needs four or more characters; with fewer it works like turns.
#
# Auto-skip (turns only): when a turn has lasted turn_minutes, the player gets
# a warning and WARNING_MINUTES more to click "I'm here!" before being skipped.
module Scene::Turns
  extend ActiveSupport::Concern

  WARNING_MINUTES = 2
  THREE_POSE_MINIMUM = 4

  included do
    enum :pose_mode, { turns: "turns", free: "free", three_pose: "three_pose" }, validate: true
    belongs_to :current_turn_participant, class_name: "SceneParticipant", optional: true
  end

  def effective_pose_mode
    three_pose? && participants.size < THREE_POSE_MINIMUM ? "turns" : pose_mode
  end

  def turn_based?
    effective_pose_mode == "turns"
  end

  def turn_of?(participant)
    turn_based? && participant.present? && current_turn_participant_id == participant.id
  end

  # Posting now would be out of turn (allowed, but the player is warned first).
  def out_of_turn?(participant)
    turn_based? && current_turn_participant_id.present? && current_turn_participant_id != participant.id
  end

  # How many more poses by others this character must wait for (3-pose rule).
  def poses_to_wait_for(participant)
    return 0 unless effective_pose_mode == "three_pose"

    last_own = poses.where(kind: "passage", character_id: participant.character_id).maximum(:sequence)
    return 0 unless last_own

    others_since = poses.where(kind: "passage").where("sequence > ?", last_own).where.not(character_id: participant.character_id).count
    [ 3 - others_since, 0 ].max
  end

  # When the turn timer will next act: the warning, or the skip.
  def turn_deadline
    return unless auto_skip_running?
    turn_warned_at ? turn_warned_at + WARNING_MINUTES.minutes : turn_started_at + turn_minutes.minutes
  end

  def auto_skip_running?
    auto_skip? && turn_based? && current_turn_participant_id.present? && turn_started_at.present? && participants.size > 1
  end

  def pass!(participant)
    with_lock do
      next false unless turn_of?(participant)
      add_system_line!("#{participant.character.name} passes.")
      advance_turn!
      true
    end
  end

  # Storytellers (and only they) can skip whoever's turn it is.
  def skip!(by:)
    with_lock do
      next false unless by&.storyteller? && turn_based? && current_turn_participant
      add_system_line!("#{by.character.name} skips #{current_turn_participant.character.name}'s turn.")
      advance_turn!
      true
    end
  end

  # "I'm here!": the player whose turn it is gets a fresh turn timer.
  def still_here!(participant)
    with_lock do
      next false unless turn_of?(participant)
      give_turn_to!(participant)
      true
    end
  end

  # Called by TurnTimerJob. The token makes a job for an older turn do nothing.
  def run_turn_timer!(token)
    with_lock do
      next unless token == turn_token && auto_skip_running?

      if turn_warned_at.nil?
        update!(turn_warned_at: Time.current)
        schedule_turn_timer
      elsif Time.current >= turn_deadline - 1.second
        add_system_line!("#{current_turn_participant.character.name}'s turn was skipped.")
        advance_turn!
      end
    end
  end

  private
    def after_pose_by(participant)
      return unless turn_based?
      advance_turn!(from: participant) if current_turn_participant_id.nil? || current_turn_participant_id == participant.id
    end

    def advance_turn!(from: current_turn_participant)
      give_turn_to!(next_participant_after(from))
    end

    def give_turn_to!(participant)
      update!(current_turn_participant: participant, turn_started_at: participant && Time.current,
        turn_warned_at: nil, turn_token: turn_token + 1)
      schedule_turn_timer
    end

    def next_participant_after(participant)
      list = participants.reload.to_a
      return if list.empty?
      index = list.index { |p| p.id == participant&.id }
      index ? list[(index + 1) % list.size] : list.first
    end

    def check_turn_still_valid!
      give_turn_to!(nil) if participants.empty? && current_turn_participant_id
    end

    def schedule_turn_timer
      TurnTimerJob.set(wait_until: turn_deadline).perform_later(self, turn_token) if auto_skip_running?
    end
end
