# A character's place in a faction, with an optional title such as "Matriarch"
# or "Apprentice". Heads can add and remove members; only staff choose heads.
# A secret membership is seen by the character's player, the heads and staff.
class FactionMembership < ApplicationRecord
  belongs_to :faction
  belongs_to :character

  normalizes :title, with: ->(t) { t.squish.presence }
  validates :title, length: { maximum: 60 }
  validates :character_id, uniqueness: { scope: :faction_id, message: "is already a member" }

  def visible_to?(account)
    return false unless faction.visible_to?(account)
    !secret? || faction.manageable_by?(account) || character.account_id == account&.id
  end
end
