# A Chapter's players ticking "Storyteller wanted", which lists it for
# players with the Storyteller flag, or taking the tick off.
class Scenes::StorytellerWantedsController < Scenes::BaseController
  before_action :require_character, :require_participant
  limit_posting to: 5, within: 10.minutes

  def create
    unless @scene.want_storyteller!(by: current_character)
      return redirect_to @scene, alert: "Only an open #{Term[:scene].downcase} that anyone can join, without a #{Term[:storyteller]} already, can ask for one."
    end
    redirect_to @scene, notice: "Asked for a #{Term[:storyteller]}. #{Term[:storyteller, count: 2]} can see it on their list."
  end

  def destroy
    @scene.stop_wanting_storyteller!
    redirect_to @scene
  end
end
