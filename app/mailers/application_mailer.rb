class ApplicationMailer < ActionMailer::Base
  # Set MAIL_FROM on the server, e.g. "Inkwll <hello@yourgame.com>".
  default from: ENV.fetch("MAIL_FROM", "Inkwll <no-reply@example.com>")
  layout "mailer"
end
