# Building tools: create and edit rooms (Settings).
class Admin::RoomsController < Admin::BaseController
  require_job :build
  before_action :set_room, only: %i[ edit update ]

  def new
    @room = Room.new(area_id: params[:area_id])
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to edit_admin_room_path(@room), notice: "#{Term[:room]} created. Add #{Term[:exit, count: 2].downcase} below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @room.update(room_params)
      redirect_to room_path(@room), notice: "#{Term[:room]} saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      params.expect(room: [ :name, :summary, :description, :icon, :remove_icon, :image, :remove_image, :background, :remove_background, :area_id, :area_default, :starting, :kind ])
    end
end
