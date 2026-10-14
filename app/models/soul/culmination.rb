# A major milestone in a character's story, proposed by the player and
# approved by staff.
class Soul::Culmination < ApplicationRecord
  belongs_to :character
  belongs_to :reviewed_by, class_name: "Account", optional: true

  enum :status, { proposed: "proposed", approved: "approved", denied: "denied", revoked: "revoked" }, validate: true

  scope :newest_first, -> { order(created_at: :desc) }

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 5_000 }
end
