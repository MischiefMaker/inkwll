# Building tools: add a batch of numbered rooms (apartments, hotel rooms...)
# off a Setting, each with a numbered Path in and a Path back out.
class Admin::NumberedRoomsController < Admin::BaseController
  require_job :build
  limit_posting to: 10, within: 10.minutes, only: :create

  def create
    @room = Room.find(params[:room_id])
    numbered = NumberedRooms.new(room: @room, lines: params[:lines], return_name: params[:return_name])
    if numbered.save
      redirect_to edit_admin_room_path(@room), notice: "Added #{numbered.rooms.size} numbered #{Term[:room, count: numbered.rooms.size].downcase}."
    else
      redirect_to edit_admin_room_path(@room, lines: params[:lines]), alert: numbered.errors.full_messages.first(5).to_sentence
    end
  end
end
