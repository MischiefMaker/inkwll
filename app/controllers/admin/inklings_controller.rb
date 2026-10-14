# Every Inkling staff can see: waiting for an answer first, then the rest.
# Drafts never show here; staff only see an Inkling once it's sent to them.
class Admin::InklingsController < Admin::BaseController
  include InklingsRequired
  require_job :review_apps

  def index
    @waiting = Inkling.submitted.open.includes(character: :account).order(:submitted_at)
    @status = params[:status].presence_in(%w[ open closed ]) || "open"
    @inklings = Inkling.staff_visible.where(status: @status).where.not(review_state: "submitted")
      .includes(:character).newest_first.limit(200)
  end
end
