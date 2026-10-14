# Puts idle characters back on the roster, when their players chose that.
class RosterIdleJob < ApplicationJob
  def perform
    Character.release_idle!
  end
end
