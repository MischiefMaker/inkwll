# Approving or turning down an application to play a roster character.
class Admin::RosterApplicationsController < Admin::BaseController
  require_job :review_apps

  def update
    application = RosterApplication.pending.find(params[:id])
    if params[:decision] == "approve"
      application.approve!(by: current_account)
      redirect_to admin_roster_path, notice: "#{application.character.name} now belongs to #{application.account.display_name}."
    else
      application.deny!(by: current_account, reason: params[:reason])
      redirect_to admin_roster_path, notice: "Application turned down."
    end
  end
end
