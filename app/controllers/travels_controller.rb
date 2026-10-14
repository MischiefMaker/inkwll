# Moves the active character straight to a Setting without walking the
# Paths: the front page's Enter button (to an Area's entrance) and My places.
# Setting pages no longer offer it, so players walk (owner, 2026-10-14).
class TravelsController < ApplicationController
  before_action :require_character

  def create
    room = Room.find(params[:room_id])
    current_character.update!(room: room)
    current_account.remember_character(current_character, room)
    redirect_to room_path(room)
  end
end
