# For Grimoire pages and actions: stops them unless the game has both SOUL
# and Grimoire switched on.
module GrimoireRequired
  extend ActiveSupport::Concern

  included do
    before_action { raise ActiveRecord::RecordNotFound unless Grimoire.enabled? }
  end
end
