# A page's history: every saved version, and putting an old one back.
class WikiPages::RevisionsController < WikiPages::BaseController
  limit_posting to: 10, within: 10.minutes, only: :update
  before_action :set_page
  before_action :set_revision, only: %i[ show update ]

  def index
    @revisions = @page.revisions.includes(:account).limit(200)
  end

  def show
  end

  # Puts this version back, as a new revision, so the undo can be undone too.
  def update
    return redirect_to(wiki_page_path(@page), alert: "Only staff can change this page.") unless @page.editable_by?(current_account)
    @page.assign_attributes(title: @revision.title, body: @revision.body)
    @page.save_revision!(by: current_account, summary: "Put back the version from #{@revision.created_at.to_fs(:long)}")
    redirect_to wiki_page_path(@page), notice: "Old version put back."
  rescue ActiveRecord::RecordInvalid
    redirect_to wiki_page_revisions_path(@page), alert: @page.errors.full_messages.to_sentence
  end

  private
    def set_revision
      @revision = @page.revisions.find(params[:id])
    end
end
