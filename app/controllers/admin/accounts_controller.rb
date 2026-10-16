# Staff management: set a player's staff level, Page jobs and Storyteller flag.
# Scribes manage Pages and Storytellers, Wellkeepers also manage Scribes, and
# only Founders can make Wellkeepers. The Founder flag itself is only set from
# the server's command line.
#
# Accounts are archived, not deleted: the player can't log in and their
# characters are retired, or go on the roster if they asked for that. Only a
# Founder can delete an account, and only one that never had characters.
#
# Staff can also make a password reset link for a player, mainly for games
# where email is optional and the player has none to get one by.
class Admin::AccountsController < Admin::BaseController
  require_job :manage_staff
  before_action :set_account, only: %i[ edit update unmute archive destroy reset_link ]
  before_action :require_manageable, only: %i[ edit update archive destroy reset_link ]
  limit_posting to: 10, within: 10.minutes, only: :reset_link

  PER_PAGE = 50

  def index
    scope = Account.where(system: false)
    @pages = [ (scope.count / PER_PAGE.to_f).ceil, 1 ].max
    @page = params[:page].to_i.clamp(1, @pages)
    @accounts = scope.includes(icon_attachment: :blob).order(:archived_at, staff_level: :desc, username: :asc)
      .offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    # Who has any characters at all, in one question instead of one per row.
    @with_characters = Character.where(account_id: @accounts.map(&:id)).distinct.pluck(:account_id).to_set
  end

  def archive
    @account.archive!
    redirect_to admin_accounts_path, notice: "#{@account.display_name} has been archived."
  end

  def destroy
    unless current_account.founder? && @account.characters.none?
      return redirect_to admin_accounts_path, alert: "Only a #{Term[:founder]} can delete an account, and only one that never had characters."
    end
    if @account.destroy
      redirect_to admin_accounts_path, notice: "#{@account.display_name} has been deleted."
    else
      redirect_to admin_accounts_path, alert: @account.errors.full_messages.to_sentence.presence || "#{@account.display_name} couldn't be deleted."
    end
  rescue ActiveRecord::InvalidForeignKey
    redirect_to admin_accounts_path, alert: "#{@account.display_name} has left things in the game that need their account, so archive it instead."
  end

  def edit
  end

  # Shows the link on the page, once, for staff to send to the player.
  def reset_link
    @reset_link = edit_password_url(@account.generate_token_for(:staff_password_reset))
    render :edit
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
      @account = Account.where(system: false).find(params[:id])
    end

    def require_manageable
      deny_access unless current_account.can_manage?(@account)
    end
end
