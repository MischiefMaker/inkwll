# Archiving many players at once from the tick boxes on the Players and staff
# page. Only players the staff member may manage are archived; the rest, and
# anyone already archived, are skipped.
class Admin::AccountBatchesController < Admin::BaseController
  require_job :manage_staff
  limit_posting to: 10, within: 10.minutes, only: :create

  MAX = 200

  def create
    accounts = Account.where(system: false, archived_at: nil, id: Array(params[:account_ids]).first(MAX))
      .where.not(id: current_account.id).order(:username).select { |account| current_account.can_manage?(account) }
    return redirect_to(admin_accounts_path, alert: "Tick at least one player you can manage first.") if accounts.empty?
    return redirect_to(admin_accounts_path, alert: "Pick what to do with them.") unless params[:decision] == "archive"

    accounts.each(&:archive!)
    redirect_to admin_accounts_path, notice: "Archived #{accounts.map(&:display_name).to_sentence}."
  end
end
