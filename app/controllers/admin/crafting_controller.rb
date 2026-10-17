# Admin → Crafting: what can be made, the features items can have,
# players' feature proposals, and (Wellkeepers) the costs and limits.
class Admin::CraftingController < Admin::BaseController
  include CraftingRequired
  require_job :review_apps
  require_job :change_game_settings, only: :update

  def show
    @game_setting = GameSetting.current
    @item_types = Crafting::ItemType.ordered.includes(:skill)
    @features = Crafting::Feature.approved.ordered
    @proposals = Crafting::Feature.proposed.includes(:proposed_by).order(:created_at)
    @item_type = Crafting::ItemType.new
    @feature = Crafting::Feature.new
  end

  def update
    @game_setting = GameSetting.current
    if @game_setting.update(params.expect(game_setting: %i[ crafting_max_features crafting_highest_level crafting_minor_cost crafting_major_cost crafting_legendary_cost ]))
      redirect_to admin_crafting_path, notice: "Saved."
    else
      show
      render :show, status: :unprocessable_entity
    end
  end
end
