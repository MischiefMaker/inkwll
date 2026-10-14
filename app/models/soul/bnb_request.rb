# A player asking staff for a new Boon or Bane after their sheet is locked.
class Soul::BnbRequest < ApplicationRecord
  belongs_to :character
  belongs_to :bnb, class_name: "Soul::Bnb", foreign_key: :soul_bnb_id, inverse_of: :requests
  belongs_to :reviewed_by, class_name: "Account", optional: true

  enum :status, { pending: "pending", approved: "approved", denied: "denied" }, validate: true

  validates :level, inclusion: { in: ->(_) { Soul::Rules.bnb_levels.keys } }
  validates :explanation, presence: true, length: { maximum: 2_000 }

  def skills = Soul::Skill.where(id: skill_ids).ordered
end
