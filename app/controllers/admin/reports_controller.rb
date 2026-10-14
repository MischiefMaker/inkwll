# Reports from players. Opening one shows the reported Chapter, which staff
# can read only because it was reported.
class Admin::ReportsController < Admin::BaseController
  require_job :handle_reports

  def index
    @open = Report.unresolved.includes(:scene, :account, :pose).order(:created_at)
    @resolved = Report.where.not(resolved_at: nil).includes(:scene, :account, :resolved_by).order(resolved_at: :desc).limit(50)
  end

  def show
    @report = Report.find(params[:id])
    @scene = @report.scene
  end

  def update
    report = Report.find(params[:id])
    report.resolve!(by: current_account, note: params.dig(:report, :resolution))
    redirect_to admin_reports_path, notice: "Report closed."
  end
end
