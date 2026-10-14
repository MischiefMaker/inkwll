class AccountMailer < ApplicationMailer
  # Sent to the old address when a player changes their email.
  def email_changed(account, old_email)
    @account = account
    mail to: old_email, subject: "Your Inkwll email address was changed"
  end
end
