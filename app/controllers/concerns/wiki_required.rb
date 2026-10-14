# For wiki pages and actions: stops them when the game has the wiki
# switched off.
module WikiRequired
  extend ActiveSupport::Concern

  included do
    before_action { raise ActiveRecord::RecordNotFound unless WikiPage.enabled? }
  end
end
