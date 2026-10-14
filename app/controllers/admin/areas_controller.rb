# Building tools: create and edit Areas, which group Settings.
class Admin::AreasController < Admin::BaseController
  require_job :build
  before_action :set_area, only: %i[ edit update ]

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

  private
    def set_area
      @area = Area.find(params[:id])
    end

    def area_params
      params.expect(area: [ :name, :description, :image, :remove_image, :parent_id, :position, :entrance_room_id ])
    end
end
