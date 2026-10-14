# Staff management: set a player's staff level, Page jobs and Storyteller flag.
# Scribes manage Pages and Storytellers, Wellkeepers also manage Scribes, and
# only Founders can make Wellkeepers. The Founder flag itself is only set from
# the server's command line.
class Admin::AccountsController < Admin::BaseController
  require_job :manage_staff
  before_action :set_account, only: %i[ edit update unmute ]
  before_action :require_manageable, only: %i[ edit update ]

  def index
    @accounts = Account.order(staff_level: :desc, username: :asc)
  end

  def edit
  end

  # Lifts the short mute given to someone who kept hitting the posting limits.
  def unmute
    @account.update_column(:muted_until, nil)
    redirect_back fallback_location: admin_accounts_path, notice: "#{@account.display_name} can post again."
  end

  def update
    attributes = params.expect(account: [ :staff_level, :storyteller, job_flags: [] ])
    level = attributes[:staff_level].presence&.to_sym

    if level && !current_account.assignable_staff_levels.include?(level)
      redirect_to edit_admin_account_path(@account), alert: "You can't give that staff level."
    elsif @account.update(attributes.merge(job_flags: Array(attributes[:job_flags]).compact_blank))
      redirect_to admin_accounts_path, notice: "#{@account.display_name} saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_account
      @account = Account.find(params[:id])
    end

    def require_manageable
      deny_access unless current_account.can_manage?(@account)
    end
end
