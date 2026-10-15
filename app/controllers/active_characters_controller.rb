# The character switcher dropdown in the page header.
class ActiveCharactersController < ApplicationController
  # "gm" switches staff and Storytellers to posting as their player, in the
  # Setting they're already in.
  def update
    if params[:character_id] == "gm"
      return redirect_back fallback_location: root_path, alert: "Only staff and #{Term[:storyteller].pluralize} can play as GM." unless current_account.may_storytell?
      here = current_character&.room
      character = current_account.gm!
      character.update!(room: here) if here && character.room_id != here.id
      current_account.switch_to(character)
      return redirect_to room_path(character.room), notice: "You are now posting as GM, under your player name."
    end

    character = current_account.characters.active.find(params[:character_id])
    current_account.switch_to(character)
    redirect_to room_path(character.room), notice: "You are now playing #{character.name}."
  end
end
