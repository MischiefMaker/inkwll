# For Economy pages and actions: stops them unless the game has the Economy
# switched on.
module EconomyRequired
  extend ActiveSupport::Concern

  included do
    before_action { raise ActiveRecord::RecordNotFound unless Economy.enabled? }
  end
end
