# The game's character groups (houses, factions), each with a colour for its
# characters' names. Deleting a group leaves its characters without one.
class Admin::CharacterGroupsController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_group, only: %i[ edit update destroy ]

  def index
    @groups = CharacterGroup.ordered
    @group = CharacterGroup.new
  end

  def create
    @group = CharacterGroup.new(group_params)
    @group.position = CharacterGroup.maximum(:position).to_i + 1
    if @group.save
      redirect_to admin_character_groups_path, notice: "#{@group.name} added."
    else
      @groups = CharacterGroup.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to admin_character_groups_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to admin_character_groups_path, notice: "#{@group.name} deleted."
  end

  private
    def set_group
      @group = CharacterGroup.find(params[:id])
    end

    def group_params
      params.expect(character_group: [ :name, :colour, :description, :position ])
    end
end
