# One line in an item's history: made, bought, given, traded, sold, or
# changed by staff (always with a reason). Kept even if the item is gone.
class Crafting::ItemEvent < ApplicationRecord
  KINDS = {
    "made" => "Made",
    "bought" => "Bought in a shop",
    "given" => "Given",
    "traded" => "Traded",
    "sold" => "Sold on the Market",
    "reward" => "Inkling reward",
    "staff_give" => "Given by staff",
    "staff_take" => "Taken by staff",
    "staff_edit" => "Changed by staff"
  }.freeze

  belongs_to :item, class_name: "Crafting::Item", optional: true
  belongs_to :character, optional: true
  belongs_to :other_character, class_name: "Character", optional: true
  belongs_to :actor, class_name: "::Account", optional: true

  validates :kind, inclusion: { in: KINDS.keys }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def kind_name = KINDS.fetch(kind, kind.humanize)
end
