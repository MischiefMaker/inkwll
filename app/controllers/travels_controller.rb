# "Travel here": moves the active character straight to a Setting they're
# looking at, without walking the Paths.
class TravelsController < ApplicationController
  before_action :require_character

  def create
    room = Room.find(params[:room_id])
    current_character.update!(room: room)
    current_account.remember_character(current_character, room)
    redirect_to room_path(room)
  end
end
