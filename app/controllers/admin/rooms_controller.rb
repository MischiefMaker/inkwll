# Building tools: create and edit rooms.
class Admin::RoomsController < Admin::BaseController
  before_action :set_room, only: %i[ edit update ]

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to edit_admin_room_path(@room), notice: "Room created. Add exits below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @room.update(room_params)
      redirect_to room_path(@room), notice: "Room saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      params.expect(room: [ :name, :description, :starting ])
    end
end
