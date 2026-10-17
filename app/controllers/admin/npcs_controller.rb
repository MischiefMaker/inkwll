# Staff keeping the game's NPCs: the shared list anyone running a Chapter can
# pick from for an NPC Passage.
class Admin::NpcsController < Admin::BaseController
  require_job :review_apps
  before_action :set_npc, only: %i[ edit update destroy ]

  def index
    @npcs = Npc.ordered.with_attached_icon
    @npc = Npc.new
  end

  def create
    @npc = Npc.new(npc_params)
    if @npc.save
      redirect_to admin_npcs_path, notice: "#{@npc.name} added."
    else
      @npcs = Npc.ordered.with_attached_icon
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @npc.update(npc_params)
      redirect_to admin_npcs_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @npc.destroy
    redirect_to admin_npcs_path, notice: "#{@npc.name} deleted. Their #{Term[:pose, count: 2].downcase} keep the name."
  end

  private
    def set_npc
      @npc = Npc.find(params[:id])
    end

    def npc_params
      params.expect(npc: [ :name, :description, :notes, :icon, :remove_icon, soul_ratings: {} ])
    end
end
