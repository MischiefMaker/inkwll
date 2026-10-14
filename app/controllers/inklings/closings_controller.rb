# Closing an Inkling when there's nothing more to do (its player or staff),
# and staff reopening it.
class Inklings::ClosingsController < Inklings::BaseController
  def create
    return back(alert: "Only its player or staff can close this.") unless @inkling.owned_by?(current_account) || staff_view?
    @inkling.close!(who: @inkling.owned_by?(current_account) ? @inkling.character.name : "Staff")
    back(notice: "Closed.")
  end

  def destroy
    return back(alert: "Only staff can reopen this.") unless staff_view?
    @inkling.reopen!
    back(notice: "Reopened.")
  end
end
