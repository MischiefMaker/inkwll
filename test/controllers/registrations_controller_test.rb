require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "signing up creates an account, logs in and asks for a character" do
    assert_difference "Account.count" do
      post registration_path, params: { account: { display_name: "Newbie", email: "newbie@example.com", password: "Secret12345", password_confirmation: "Secret12345" } }
    end

    assert_redirected_to new_character_path
    assert cookies["inkwll_login"]
  end

  test "players can opt in to email notifications when signing up" do
    post registration_path, params: { account: { display_name: "Newbie", email: "newbie@example.com", email_notifications: "when_away", password: "Secret12345", password_confirmation: "Secret12345" } }

    assert_equal "when_away", Account.find_by(username: "newbie").email_notifications
  end

  test "email notifications are off unless the player opts in" do
    post registration_path, params: { account: { display_name: "Newbie", email: "newbie@example.com", password: "Secret12345", password_confirmation: "Secret12345" } }

    assert_equal "off", Account.find_by(username: "newbie").email_notifications
  end

  test "invalid sign up shows the form again" do
    post registration_path, params: { account: { display_name: "", password: "x", password_confirmation: "y" } }
    assert_response :unprocessable_entity
  end
end
