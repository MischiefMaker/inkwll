# Moves the active character through an exit (clicking an exit link).
class MovementsController < ApplicationController
  before_action :require_character

  def create
    chosen_exit = Exit.find(params[:exit_id])

    if chosen_exit.source_room_id == current_character.room_id
      current_character.move_through(chosen_exit)
      current_account.remember_character(current_character, current_character.room)
      redirect_to room_path(current_character.room)
    else
      redirect_to room_path(current_character.room), alert: "#{current_character.name} isn't in the right room to use that exit."
    end
  end
end
