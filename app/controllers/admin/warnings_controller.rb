# Staff sending a player a warning, usually from a report.
class Admin::WarningsController < Admin::BaseController
  require_job :handle_reports

  def new
    @warning = AccountWarning.new(account_id: params[:account_id], report_id: params[:report_id])
  end

  def create
    @warning = AccountWarning.new(staff: current_account, **params.expect(account_warning: [ :account_id, :report_id, :body ]))
    if @warning.save
      redirect_to(@warning.report ? admin_report_path(@warning.report) : admin_accounts_path, notice: "Warning sent to #{@warning.account.display_name}.")
    else
      render :new, status: :unprocessable_entity
    end
  end
end
