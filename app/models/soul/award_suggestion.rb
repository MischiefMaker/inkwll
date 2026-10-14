# A Storyteller suggesting XP for a player in a Chapter they ran. Nothing is
# given until staff approve it (owner, 2026-10-14).
class Soul::AwardSuggestion < ApplicationRecord
  MAX_AMOUNT = 10

  belongs_to :character
  belongs_to :scene
  belongs_to :suggested_by, class_name: "Account"
  belongs_to :reviewed_by, class_name: "Account", optional: true

  enum :status, { pending: "pending", approved: "approved", denied: "denied" }, validate: true

  validates :amount, numericality: { only_integer: true, in: 1..MAX_AMOUNT }
  validates :reason, presence: true, length: { maximum: 1_000 }

  def approve!(by:)
    transaction do
      character.award_xp!(amount, source: "storyteller", actor: by, note: reason.first(200))
      update!(status: "approved", reviewed_by: by, reviewed_at: Time.current)
      Soul::AuditEntry.record!("award_approved", "Approved #{amount} XP suggested by #{suggested_by.display_name} for #{scene.title}",
        actor: by, character: character)
    end
  end

  def deny!(by:, reason:)
    update!(status: "denied", staff_reason: reason.to_s.strip.first(250).presence, reviewed_by: by, reviewed_at: Time.current)
    Soul::AuditEntry.record!("award_denied", "Turned down #{amount} XP suggested by #{suggested_by.display_name}", actor: by, character: character, reason: reason)
  end
end
