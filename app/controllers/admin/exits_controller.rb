# Building tools: add and remove exits from a room.
class Admin::ExitsController < Admin::BaseController
  before_action :set_room

  def create
    @exit = @room.exits.new(params.expect(exit: [ :name, :destination_room_id ]))
    if @exit.save
      redirect_to edit_admin_room_path(@room), notice: "Exit added."
    else
      redirect_to edit_admin_room_path(@room), alert: @exit.errors.full_messages.to_sentence
    end
  end

  def destroy
    @room.exits.find(params[:id]).destroy
    redirect_to edit_admin_room_path(@room), notice: "Exit removed."
  end

  private
    def set_room
      @room = Room.find(params[:room_id])
    end
end
