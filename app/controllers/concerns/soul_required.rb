# For SOUL pages and actions: stops them when the game has SOUL switched off.
module SoulRequired
  extend ActiveSupport::Concern

  included do
    before_action { raise ActiveRecord::RecordNotFound unless Soul.enabled? }
  end
end
