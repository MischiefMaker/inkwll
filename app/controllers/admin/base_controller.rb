# Parent of all staff-only pages. Non-admins are turned away.
class Admin::BaseController < ApplicationController
  before_action :require_admin

  private
    def require_admin
      redirect_to root_path, alert: "Staff only." unless current_account.admin?
    end
end
