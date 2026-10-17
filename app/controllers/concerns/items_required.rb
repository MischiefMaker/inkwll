# Items, shops, Give and Trade live under the Economy switch.
module ItemsRequired
  extend ActiveSupport::Concern

  included do
    before_action -> { raise ActiveRecord::RecordNotFound unless Crafting.items_enabled? }
  end
end
