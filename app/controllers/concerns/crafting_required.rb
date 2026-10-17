# Making items, features and the Market need Crafting switched on.
module CraftingRequired
  extend ActiveSupport::Concern

  included do
    before_action -> { raise ActiveRecord::RecordNotFound unless Crafting.enabled? }
  end
end
