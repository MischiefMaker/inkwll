class PasswordsMailer < ApplicationMailer
  def reset(account)
    @account = account
    mail to: account.email, subject: "Reset your Inkwll password"
  end
end
