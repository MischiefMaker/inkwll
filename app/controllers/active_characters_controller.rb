# The character switcher dropdown in the page header.
class ActiveCharactersController < ApplicationController
  def update
    character = current_account.characters.active.find(params[:character_id])
    current_account.switch_to(character)
    redirect_to room_path(character.room), notice: "You are now playing #{character.name}."
  end
end
