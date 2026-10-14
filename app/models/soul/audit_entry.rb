# Staff-only record of every staff change to SOUL: who did what, and why.
class Soul::AuditEntry < ApplicationRecord
  belongs_to :character, optional: true
  belongs_to :actor, class_name: "Account", optional: true
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def self.record!(action, summary, actor:, character: nil, reason: nil)
    create!(action: action, summary: summary.first(250), actor: actor, character: character, reason: reason.to_s.strip.presence&.first(250))
  end
end
