# Parent of all admin panel pages. Only staff (Pages, Scribes, Wellkeepers)
# get in, and each section asks for the job it needs with `require_job`.
class Admin::BaseController < ApplicationController
  before_action :require_staff

  def self.require_job(job, **options)
    before_action(**options) { deny_access unless current_account.can?(job) }
  end

  private
    def require_staff
      deny_access unless current_account.staff?
    end

    def deny_access
      redirect_to root_path, alert: "You don't have access to that."
    end
end
