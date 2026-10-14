# Emails a player that it's their turn, if it still is (see Notifier).
class TurnEmailJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(participant, token, away_only: false)
    scene = participant.scene.reload
    account = participant.character.account
    return unless scene.turn_token == token && scene.turn_of?(participant)
    return if away_only && account.online?

    passages = participant.unread_passages.to_a
    NotificationMailer.your_turn(participant, passages.last(Notifier::PASSAGES_PER_EMAIL), passages.size - Notifier::PASSAGES_PER_EMAIL).deliver_now
    participant.mark_emailed!
  end
end
