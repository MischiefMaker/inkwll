# One line in a character's XP ledger: an award, a spend or a staff
# correction. A character's XP is always worked out from these lines.
class Soul::XpEntry < ApplicationRecord
  belongs_to :character
  belongs_to :actor, class_name: "Account", optional: true
  belongs_to :trait, polymorphic: true, optional: true

  enum :kind, { award: "award", spend: "spend", correction: "correction" }, validate: true

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  validates :amount, numericality: { only_integer: true, other_than: 0 }
  validates :note, length: { maximum: 200 }

  def total = amount + catchup_amount

  def description
    case kind
    when "award" then { "weekly" => "Weekly XP", "scene" => "Finished #{Term[:scene]}", "staff" => "Awarded by staff" }.fetch(source.to_s, "Award")
    when "spend" then "Raised #{trait&.name || "a trait"} to #{new_rating}"
    else "Corrected by staff"
    end
  end
end
