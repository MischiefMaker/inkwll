require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "emails come from the game's name at MAIL_FROM_ADDRESS" do
    GameSetting.current.update!(game_name: "Moonfall")
    with_env("MAIL_FROM_ADDRESS" => "no-reply@inkwll.com", "MAIL_FROM" => nil) do
      email = PasswordsMailer.reset(accounts(:alice))
      assert_equal [ "no-reply@inkwll.com" ], email.from
      assert_equal "Moonfall <no-reply@inkwll.com>", email[:from].value
    end
  end

  test "MAIL_FROM replaces the whole from line" do
    with_env("MAIL_FROM" => "Staff <staff@example.org>") do
      assert_equal [ "staff@example.org" ], PasswordsMailer.reset(accounts(:alice)).from
    end
  end

  private

  def with_env(values)
    old = values.keys.to_h { |key| [ key, ENV[key] ] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    old.each { |key, value| ENV[key] = value }
  end
end
