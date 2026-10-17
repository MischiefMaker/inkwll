# A catalogue item for sale in a Place's shop, at its catalogue price.
class Crafting::ShopListing < ApplicationRecord
  belongs_to :room
  belongs_to :catalogue_item, class_name: "Crafting::CatalogueItem"
end
