# Finishing a Chapter (it moves to the Archives) and undoing that within a day.
class Scenes::FinishesController < Scenes::BaseController
  before_action :require_character, :require_participant

  def create
    if @scene.finish!(by: current_character)
      redirect_to @scene, notice: "Finished. The others can undo this for #{Scene::UNDO_FINISH_WITHIN.in_hours.to_i} hours."
    else
      redirect_to @scene
    end
  end

  def destroy
    if @scene.reopen!(by: current_character)
      redirect_to @scene, notice: "Reopened."
    else
      redirect_to @scene, alert: "It's too late to undo finishing this #{Term[:scene]}."
    end
  end
end
