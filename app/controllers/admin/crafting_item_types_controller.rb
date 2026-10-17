# Adding and changing what characters can make.
class Admin::CraftingItemTypesController < Admin::BaseController
  include CraftingRequired
  require_job :review_apps
  before_action :set_item_type, only: %i[ edit update destroy ]

  def create
    item_type = Crafting::ItemType.new(item_type_params)
    item_type.position = Crafting::ItemType.maximum(:position).to_i + 1
    if item_type.save
      redirect_to admin_crafting_path, notice: "#{item_type.name} added."
    else
      redirect_to admin_crafting_path, alert: item_type.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @item_type.update(item_type_params)
      redirect_to admin_crafting_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item_type.destroy
    redirect_to admin_crafting_path, notice: "#{@item_type.name} deleted. Items already made keep their maker's mark."
  end

  private
    def set_item_type
      @item_type = Crafting::ItemType.find(params[:id])
    end

    def item_type_params
      params.expect(crafting_item_type: %i[ name description base_cost soul_skill_id position ])
    end
end
