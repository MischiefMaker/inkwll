# A player's idea for a new spell, waiting for staff. Approving it makes
# the spell (staff can adjust it first); the player still learns it with XP.
class Grimoire::Proposal < ApplicationRecord
  include AffectsStaffQueue
  belongs_to :character
  belongs_to :branch, class_name: "Grimoire::Branch"
  belongs_to :reviewed_by, class_name: "Account", optional: true
  belongs_to :spell, class_name: "Grimoire::Spell", optional: true

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, validate: true

  normalizes :name, with: ->(n) { n.squish }
  validates :name, presence: true, length: { maximum: 80 }
  validates :description, presence: true, length: { maximum: 5_000 }
  validates :minimum_rating, numericality: { only_integer: true, in: 0..20 }
  validates :difficulty_name, inclusion: { in: ->(_) { Soul::Rules.difficulties.keys } }

  def approve!(by:)
    transaction do
      spell = branch.spells.create!(name: name, description: description, minimum_rating: minimum_rating,
        difficulty_name: difficulty_name, created_by: by)
      update!(status: "approved", spell: spell, reviewed_by: by, reviewed_at: Time.current)
      spell
    end
  end

  def reject!(by:, reason:)
    update!(status: "rejected", staff_reason: reason.to_s.strip.first(250).presence, reviewed_by: by, reviewed_at: Time.current)
  end
end
