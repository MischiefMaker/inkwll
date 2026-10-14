# The front page sends players to wherever their active character is.
class HomeController < ApplicationController
  before_action :require_character

  def show
    redirect_to room_path(current_character.room)
  end
end
