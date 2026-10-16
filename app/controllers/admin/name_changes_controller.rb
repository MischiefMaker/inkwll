# A log of players and characters being renamed, newest first, for staff.
class Admin::NameChangesController < Admin::BaseController
  require_job :review_apps

  PER_PAGE = 50

  def index
    scope = NameChange.newest_first.includes(:subject, :changed_by)
    @pages = [ (scope.count / PER_PAGE.to_f).ceil, 1 ].max
    @page = params[:page].to_i.clamp(1, @pages)
    @name_changes = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end
end
