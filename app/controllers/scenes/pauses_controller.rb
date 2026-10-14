# Pausing a Chapter to pick it up another day, and picking it back up.
class Scenes::PausesController < Scenes::BaseController
  before_action :require_character, :require_participant

  def create
    @scene.pause!(by: current_character, note: params[:note])
    redirect_to @scene
  end

  def destroy
    @scene.resume!(by: current_character)
    redirect_to @scene
  end
end
