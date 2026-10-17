# The item catalogue: ready-made items staff sell in shops and give as
# rewards, and the Places whose shops sell each one.
class Admin::CatalogueItemsController < Admin::BaseController
  include ItemsRequired
  require_job :review_apps
  before_action :set_catalogue_item, only: %i[ edit update destroy ]

  def index
    @catalogue_items = Crafting::CatalogueItem.ordered.includes(:rooms, image_attachment: :blob)
    @catalogue_item = Crafting::CatalogueItem.new
  end

  def create
    @catalogue_item = Crafting::CatalogueItem.new(catalogue_item_params)
    @catalogue_item.position = Crafting::CatalogueItem.maximum(:position).to_i + 1
    if @catalogue_item.save
      redirect_to admin_catalogue_items_path, notice: "#{@catalogue_item.name} added."
    else
      @catalogue_items = Crafting::CatalogueItem.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @catalogue_item.update(catalogue_item_params)
      redirect_to admin_catalogue_items_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @catalogue_item.destroy
    redirect_to admin_catalogue_items_path, notice: "#{@catalogue_item.name} deleted. Characters who own one keep it."
  end

  private
    def set_catalogue_item
      @catalogue_item = Crafting::CatalogueItem.find(params[:id])
    end

    def catalogue_item_params
      params.expect(crafting_catalogue_item: [ :name, :description, :price, :image, :position, feature_ids: [], room_ids: [] ]).tap do |attributes|
        attributes[:feature_ids] = Array(attributes[:feature_ids]).compact_blank.map(&:to_i) if attributes.key?(:feature_ids)
      end
    end
end
