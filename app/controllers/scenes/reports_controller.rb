# Reporting a Chapter, or one Passage in it, to staff.
class Scenes::ReportsController < Scenes::BaseController
  before_action :require_reader

  def new
    @report = @scene.reports.new(pose: @scene.poses.find_by(id: params[:pose_id]))
  end

  def create
    @report = @scene.reports.new(account: current_account, **params.expect(report: [ :reason, :pose_id ]))
    if @report.save
      redirect_to @scene, notice: "Thank you. Staff will look at your report."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def require_reader
      raise ActiveRecord::RecordNotFound unless @scene.readable_by?(current_account)
    end
end
