# Approving new players, in games where new accounts wait for staff. Turning
# one away archives the account, so it can't log in.
class Admin::AccountApprovalsController < Admin::BaseController
  require_job :manage_staff

  def update
    account = Account.waiting_for_approval.find(params[:id])
    account.update!(awaiting_approval: false)
    StaffWaiting.refresh_bells!
    redirect_to admin_accounts_path, notice: "#{account.display_name} can take part now."
  end

  def destroy
    account = Account.waiting_for_approval.find(params[:id])
    account.archive!
    StaffWaiting.refresh_bells!
    redirect_to admin_accounts_path, notice: "#{account.display_name} was turned away, and their account archived."
  end
end
