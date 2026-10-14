class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    PasswordsMailer.reset(Account.first)
  end
end
