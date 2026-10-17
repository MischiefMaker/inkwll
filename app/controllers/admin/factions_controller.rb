# The game's factions: families, guilds and clubs. Making, renaming and
# deleting them is here; members are added on each faction's own page, by
# its heads or staff.
class Admin::FactionsController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_faction, only: %i[ edit update destroy ]

  def index
    @factions = Faction.ordered
    @faction = Faction.new
  end

  def create
    @faction = Faction.new(faction_params)
    @faction.position = Faction.maximum(:position).to_i + 1
    if @faction.save
      redirect_to admin_factions_path, notice: "#{@faction.name} added."
    else
      @factions = Faction.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @faction.update(faction_params)
      redirect_to admin_factions_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @faction.destroy
    redirect_to admin_factions_path, notice: "#{@faction.name} deleted."
  end

  private
    def set_faction
      @faction = Faction.find(params[:id])
    end

    def faction_params
      params.expect(faction: [ :name, :description, :npc_heads, :secret, :pick_on_application, :position ])
    end
end
