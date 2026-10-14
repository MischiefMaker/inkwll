# Passing your turn, a storyteller skipping someone, and "I'm here!".
class Scenes::TurnsController < Scenes::BaseController
  before_action :require_character, :require_participant

  def pass
    flash[:alert] = "It isn't #{current_character.name}'s turn." unless @scene.pass!(participant)
    redirect_to @scene
  end

  def skip
    flash[:alert] = "Only a storyteller can skip a turn." unless @scene.skip!(by: participant)
    redirect_to @scene
  end

  def here
    @scene.still_here!(participant)
    redirect_to @scene
  end
end
