# Building tools: create, edit and delete rooms (Settings).
class Admin::RoomsController < Admin::BaseController
  require_job :build
  before_action :set_room, only: %i[ edit update destroy ]

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

  # A Setting is only deleted when nobody is in it and it has no Chapters, so
  # nothing in the Archives is lost. Its Paths (and the Paths leading to it)
  # go with it.
  def destroy
    area = @room.area
    if @room.deletable? && @room.destroy
      redirect_to admin_areas_path, notice: "#{Term[:room]} deleted."
    else
      redirect_to edit_admin_room_path(@room), alert: "Can't delete #{@room.name}: #{@room.deletion_blockers.to_sentence.presence || @room.errors.full_messages.to_sentence}"
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
