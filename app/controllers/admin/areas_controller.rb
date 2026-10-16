# Building tools: create, edit and delete Areas, which group Settings.
class Admin::AreasController < Admin::BaseController
  require_job :build
  before_action :set_area, only: %i[ edit update destroy ]

  def index
    @areas = Area.top_level.includes(:rooms, children: :rooms)
  end

  def new
    @area = Area.new(parent_id: params[:parent_id])
  end

  def create
    @area = Area.new(area_params)
    if @area.save
      redirect_to area_path(@area), notice: "#{Term[:area]} created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @area.update(area_params)
      redirect_to area_path(@area), notice: "#{Term[:area]} saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # An Area is only deleted when it is empty.
  def destroy
    if @area.deletable? && @area.destroy
      redirect_to admin_areas_path, notice: "#{Term[:area]} deleted."
    else
      redirect_to edit_admin_area_path(@area), alert: "Can't delete #{@area.name}: #{@area.deletion_blockers.to_sentence.presence || @area.errors.full_messages.to_sentence}"
    end
  end

  private
    def set_area
      @area = Area.find(params[:id])
    end

    def area_params
      params.expect(area: [ :name, :summary, :description, :icon, :remove_icon, :image, :remove_image, :background, :remove_background, :parent_id, :position, :entrance_room_id ])
    end
end
