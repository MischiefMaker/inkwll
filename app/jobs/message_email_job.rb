# Emails a player about new Messages in a conversation (see Notifier).
class MessageEmailJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(member, away_only: false)
    Notifier.email_conversation(member.reload, away_only: away_only)
  end
end
