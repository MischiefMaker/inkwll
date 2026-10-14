# Moves the active character straight to a Setting without walking the
# Paths: "Travel here" on a Setting seen from afar, the front page's Enter
# button (to an Area's entrance) and My places.
class TravelsController < ApplicationController
  before_action :require_character

  def create
    room = Room.find(params[:room_id])
    current_character.update!(room: room)
    current_account.remember_character(current_character, room)
    redirect_to room_path(room)
  end
end
