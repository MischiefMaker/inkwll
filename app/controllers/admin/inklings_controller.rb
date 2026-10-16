# Every Inkling staff can see: waiting for an answer first, then the rest.
# Drafts never show here; staff only see an Inkling once it's sent to them.
class Admin::InklingsController < Admin::BaseController
  include InklingsRequired
  require_job :review_apps

  PER_PAGE = 25
  DAY_CHOICES = [ 30, 90, 180, 365 ].freeze
  DEFAULT_DAYS = 90

  # The second list only holds Inklings with something new in the last @days
  # days (0 means all of them), a page at a time.
  def index
    @waiting = Inkling.submitted.open.includes(character: :account).order(:submitted_at)
    @status = params[:status].presence_in(%w[ open closed ]) || "open"
    @days = params[:days].present? ? params[:days].to_i : DEFAULT_DAYS
    @days = DEFAULT_DAYS unless @days.zero? || DAY_CHOICES.include?(@days)
    scope = Inkling.staff_visible.where(status: @status).where.not(review_state: "submitted")
    scope = scope.where("COALESCE(inklings.last_entry_at, inklings.created_at) >= ?", @days.days.ago) if @days.positive?
    @pages = [ (scope.count / PER_PAGE.to_f).ceil, 1 ].max
    @page = params[:page].to_i.clamp(1, @pages)
    @inklings = scope.includes(:character).newest_first.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end
end
