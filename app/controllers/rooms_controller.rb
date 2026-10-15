class RoomsController < ApplicationController
  allow_previews only: %i[ index show ]

  def index
    @rooms = Room.includes(:area).order(:name)
  end

  def show
    @room = Room.find(params[:id])
    if current_account
      use_remembered_character
    else
      session[:guest_token] ||= SecureRandom.hex(16)
      GuestVisit.note!(token: session[:guest_token], room: @room, user_agent: request.user_agent)
    end
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
