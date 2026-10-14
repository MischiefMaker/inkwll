# Staff deciding on a submitted Inkling: approving this round, or sending it
# back for changes. Replying is never a decision.
class Inklings::ReviewsController < Inklings::BaseController
  before_action :require_staff_view

  def create
    if params[:decision] == "approve"
      @inkling.approve!(by: current_account)
      back(notice: "Approved. #{@inkling.character.name}'s player can carry on with it.")
    else
      @inkling.request_changes!(by: current_account, note: params[:note].to_s.strip)
      back(notice: "Sent back for changes.")
    end
  rescue ArgumentError => e
    back(alert: e.message)
  end
end
