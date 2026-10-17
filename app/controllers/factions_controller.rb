# The game's factions and who is in them. Guests and players see the open
# ones; a secret faction is only shown to its members and staff.
class FactionsController < ApplicationController
  allow_previews
  before_action -> { raise ActiveRecord::RecordNotFound unless Faction.enabled? }

  def index
    @factions = Faction.visible_to(current_account).ordered
    @waiting = FactionRequest.pending.group(:faction_id).count
  end

  def show
    @faction = Faction.visible_to(current_account).find(params[:id])
    @memberships = @faction.visible_memberships_for(current_account)
    @manager = @faction.manageable_by?(current_account)
    @staff = Faction.staff?(current_account)
    @requests = @manager ? @faction.requests.pending.includes(:character).order(:created_at) : FactionRequest.none
    @own_requests = current_account ? @faction.requests.pending.where(character: current_account.characters).includes(:character) : FactionRequest.none
    @askable = FactionRequest.askable_characters(current_account, @faction)
    Alert.read_for_faction!(current_account, @faction) if current_account
  end
end
