# An item (or part of a stack) one side puts into a Trade.
class Crafting::TradeItem < ApplicationRecord
  belongs_to :trade, class_name: "Crafting::Trade"
  belongs_to :item, class_name: "Crafting::Item"

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
