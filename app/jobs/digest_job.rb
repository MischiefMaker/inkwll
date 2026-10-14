# Runs once a day: players who chose "only after I've been away a while" and
# have been away that many days get one email covering every Chapter with
# Passages they haven't seen (and haven't been emailed about).
class DigestJob < ApplicationJob
  queue_as :default

  def perform
    Account.where(email_notifications: "after_days").where.not(email: nil).find_each do |account|
      next if account.last_seen_at && account.last_seen_at > account.email_after_days.days.ago

      entries = SceneParticipant.joins(:scene).merge(Scene.open).where(character: account.characters).includes(:scene).filter_map do |participant|
        next if participant.emailed_since_last_read?
        next if account.only_turn_emails_for?(participant.scene) && !participant.scene.turn_of?(participant)
        passages = participant.unread_passages.to_a
        [ participant, passages.last(Notifier::PASSAGES_PER_EMAIL), passages.size - Notifier::PASSAGES_PER_EMAIL ] if passages.any?
      end
      next if entries.empty?

      NotificationMailer.digest(account, entries).deliver_now
      entries.each { |participant, _, _| participant.mark_emailed! }
    end
  end
end
