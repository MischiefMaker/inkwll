# A player's own choices about activity emails and browser pop-ups.
class NotificationSettingsController < ApplicationController
  def edit
    @account = current_account
  end

  def update
    @account = current_account
    if @account.update(params.expect(account: [ :email, :email_notifications, :email_after_days, :email_only_my_turn,
                                                :browser_notifications, :browser_notify_minutes ]))
      redirect_to edit_notification_settings_path, notice: "Notification settings saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
