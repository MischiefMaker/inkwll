# A player's own choices about activity emails and browser pop-ups. Changing
# the email address here needs the current password, and the old address is
# told about the change, so a borrowed login can't take over the account.
class NotificationSettingsController < ApplicationController
  def edit
    @account = current_account
  end

  def update
    @account = current_account
    old_email = @account.email
    @account.assign_attributes(params.expect(account: [ :email, :email_notifications, :email_after_days, :email_only_my_turn,
                                                         :browser_notifications, :browser_notify_minutes ]))

    if @account.email_changed? && !@account.authenticate(params[:current_password].to_s)
      @account.errors.add(:base, "Enter your current password to change your email address")
      return render :edit, status: :unprocessable_entity
    end

    if @account.save
      AccountMailer.email_changed(@account, old_email).deliver_later if old_email.present? && old_email != @account.email
      redirect_to edit_notification_settings_path, notice: "Notification settings saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
