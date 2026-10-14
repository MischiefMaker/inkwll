# For Inkling pages and actions: stops them when the game has Inklings
# switched off.
module InklingsRequired
  extend ActiveSupport::Concern

  included do
    before_action { raise ActiveRecord::RecordNotFound unless Inkling.enabled? }
  end
end
