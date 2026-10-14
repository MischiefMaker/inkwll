# Staff hiding a Passage in a reported Chapter. The text is kept.
class Admin::HidingsController < Admin::BaseController
  require_job :handle_reports

  def create
    pose = Pose.find(params[:pose_id])
    raise ActiveRecord::RecordNotFound unless pose.scene.reported_to?(current_account)

    pose.hide_by_staff!
    redirect_back_or_to scene_path(pose.scene), notice: "#{Term[:pose]} hidden."
  end
end
