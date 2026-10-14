# Runs once a day: players who chose "only after I've been away a while" and
# have been away that many days get one email covering every Chapter with
# Passages they haven't seen, and every Messages conversation with something
# new (and haven't been emailed about).
class DigestJob < ApplicationJob
  queue_as :default

  def perform
    Account.where(email_notifications: "after_days", archived_at: nil).where.not(email: nil).find_each do |account|
      next if account.last_seen_at && account.last_seen_at > account.email_after_days.days.ago

      entries = SceneParticipant.joins(:scene).merge(Scene.open).where(character: account.characters).includes(:scene).filter_map do |participant|
        next if participant.emailed_since_last_read?
        next if account.only_turn_emails_for?(participant.scene) && !participant.scene.turn_of?(participant)
        passages = participant.unread_passages.to_a
        [ participant, passages.last(Notifier::PASSAGES_PER_EMAIL), passages.size - Notifier::PASSAGES_PER_EMAIL ] if passages.any?
      end
      conversations = account.conversation_members.active.includes(:conversation).filter_map do |member|
        next if member.emailed_since_last_read?
        messages = member.unread_messages.to_a
        [ member, messages.last(Notifier::PASSAGES_PER_EMAIL), messages.size - Notifier::PASSAGES_PER_EMAIL ] if messages.any?
      end
      next if entries.empty? && conversations.empty?

      send_digest(account, entries, conversations)
    end
  end

  private
    # One player's email failing (say the mail service hiccups) is logged
    # and skipped, so everyone after them still gets theirs. Nothing is
    # marked as emailed, so they're tried again next time.
    def send_digest(account, entries, conversations)
      NotificationMailer.digest(account, entries, conversations).deliver_now
      entries.each { |participant, _, _| participant.mark_emailed! }
      conversations.each { |member, _, _| member.update_column(:emailed_at, Time.current) }
    rescue StandardError => e
      Rails.logger.error "Digest email to account #{account.id} failed: #{e.class}: #{e.message}"
      Rails.error.report(e, handled: true, context: { account_id: account.id })
    end
end
