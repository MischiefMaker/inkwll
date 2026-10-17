# The game's factions and who is in them. Guests and players see the open
# ones; a secret faction is only shown to its members and staff.
class FactionsController < ApplicationController
  allow_previews
  before_action -> { raise ActiveRecord::RecordNotFound unless Faction.enabled? }

  def index
    @factions = Faction.visible_to(current_account).ordered
  end

  def show
    @faction = Faction.visible_to(current_account).find(params[:id])
    @memberships = @faction.visible_memberships_for(current_account)
    @manager = @faction.manageable_by?(current_account)
    @staff = Faction.staff?(current_account)
  end
end
