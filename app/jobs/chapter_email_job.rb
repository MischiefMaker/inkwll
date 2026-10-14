# Emails a player about new Passages in one of their Chapters (see Notifier).
class ChapterEmailJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(participant, away_only: false)
    Notifier.email_chapter(participant.reload, away_only: away_only)
  end
end
