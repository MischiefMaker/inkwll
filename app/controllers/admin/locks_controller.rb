# Staff locking a reported Chapter so nobody can post in it, and unlocking it.
class Admin::LocksController < Admin::BaseController
  require_job :handle_reports
  before_action :set_scene

  def create
    @scene.update!(locked_at: Time.current)
    redirect_back_or_to scene_path(@scene), notice: "#{Term[:scene]} locked."
  end

  def destroy
    @scene.update!(locked_at: nil)
    redirect_back_or_to scene_path(@scene), notice: "#{Term[:scene]} unlocked."
  end

  private
    def set_scene
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.reported_to?(current_account)
    end
end
