# Staff lock a page so only staff can change it.
class WikiPages::LocksController < WikiPages::BaseController
  before_action :set_page
  before_action { redirect_to wiki_page_path(@page), alert: "Only staff can lock pages." unless current_account.staff? }

  def create
    @page.update!(locked_at: Time.current)
    redirect_to wiki_page_path(@page), notice: "Locked. Only staff can change it now."
  end

  def destroy
    @page.update!(locked_at: nil)
    redirect_to wiki_page_path(@page), notice: "Unlocked."
  end
end
