class RoomsController < ApplicationController
  def index
    @rooms = Room.includes(:area).order(:name)
  end

  def show
    @room = Room.find(params[:id])
    use_remembered_character
  end

  private
    # If the player last used one of their characters here, and that character
    # is still in this room, switch back to it automatically. Otherwise, if the
    # active character is here, remember it for next time.
    def use_remembered_character
      remembered = current_account.remembered_character_for(@room)
      if remembered && remembered.room_id == @room.id && remembered != current_character
        current_account.update!(active_character: remembered)
      elsif current_character&.room_id == @room.id
        current_account.remember_character(current_character, @room)
      end
    end
end
