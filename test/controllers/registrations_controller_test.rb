require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "signing up creates an account, logs in and asks for a character" do
    assert_difference "Account.count" do
      post registration_path, params: { account: { username: "newbie", display_name: "Newbie", password: "secret123", password_confirmation: "secret123" } }
    end

    assert_redirected_to new_character_path
    assert cookies[:session_id]
  end

  test "invalid sign up shows the form again" do
    post registration_path, params: { account: { username: "alice", display_name: "", password: "x", password_confirmation: "y" } }
    assert_response :unprocessable_entity
  end
end
