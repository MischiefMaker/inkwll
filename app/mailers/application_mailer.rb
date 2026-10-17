class ApplicationMailer < ActionMailer::Base
  # Emails come from the game's name at MAIL_FROM_ADDRESS (set in
  # config/deploy.yml), e.g. "Last Call of the Wild <no-reply@inkwll.com>".
  # MAIL_FROM on the server replaces the whole thing.
  default from: -> {
    ENV["MAIL_FROM"].presence ||
      email_address_with_name(ENV["MAIL_FROM_ADDRESS"].presence || "no-reply@example.com",
        GameSetting.current.game_name || ENV["INKWLL_GAME_NAME"].presence || "Inkwll")
  }
  layout "mailer"
end
