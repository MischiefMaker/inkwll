# The Storyteller sending one character a private aside in a Chapter.
class Scenes::AsidesController < Scenes::BaseController
  before_action :require_character, :require_participant
  limit_posting to: 20

  def create
    @scene.aside!(current_character, to: params[:to], body: params[:body])
    redirect_to @scene
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to @scene, alert: e.message
  end
end
