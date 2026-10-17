# A Chapter's players editing "The story so far". They can keep it up to date
# after the Chapter is finished too, but not while staff have it locked.
class Scenes::SummariesController < Scenes::BaseController
  before_action :require_character, :require_participant
  limit_posting to: 10, within: 10.minutes, only: :update

  def update
    return redirect_to @scene, alert: "Staff have locked this #{Term[:scene].downcase}." if @scene.locked?
    @scene.update_summary!(params[:summary], by: current_character)
    redirect_to @scene, notice: "The story so far is saved."
  rescue ActiveRecord::RecordInvalid
    redirect_to @scene, alert: "Keep the story so far to #{Scene::StorySoFar::SUMMARY_LENGTH} characters."
  end
end
