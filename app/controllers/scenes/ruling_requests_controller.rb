# A Chapter's players asking staff to rule on something ("Need a ruling"),
# or taking the request back.
class Scenes::RulingRequestsController < Scenes::BaseController
  before_action :require_character, :require_participant
  limit_posting to: 5, within: 10.minutes

  def create
    unless @scene.ask_for_ruling!(by: current_character, note: params[:note])
      return redirect_to @scene, alert: "Say briefly what you'd like staff to rule on."
    end
    redirect_to @scene, notice: "Asked staff for a ruling. Their answer will appear in the #{Term[:scene].downcase}."
  end

  def destroy
    @scene.withdraw_ruling!(by: current_character)
    redirect_to @scene
  end
end
