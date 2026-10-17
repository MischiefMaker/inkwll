# Staff who build the world putting a finished Chapter on the world timeline,
# or taking it off.
class Admin::WorldEventsController < Admin::BaseController
  require_job :build
  before_action :set_scene

  def create
    return redirect_to scene_path(@scene), alert: "Only a finished #{Term[:scene].downcase} can go on the timeline." unless @scene.finished?
    @scene.mark_world_event!(by: current_account, note: params[:world_event_note].to_s)
    redirect_to scene_path(@scene), notice: "On the world timeline."
  rescue ActiveRecord::RecordInvalid
    redirect_to scene_path(@scene), alert: "Keep the line to #{Scene::WorldEvent::NOTE_LENGTH} characters."
  end

  def destroy
    @scene.unmark_world_event!
    redirect_to scene_path(@scene), notice: "Taken off the world timeline."
  end

  private
    def set_scene
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
    end
end
