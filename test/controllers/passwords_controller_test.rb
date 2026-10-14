require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "asking for a reset emails a link, and the link sets a new password" do
    assert_enqueued_emails 1 do
      post passwords_path, params: { email: "Bob@example.com" }
    end
    assert_redirected_to new_session_path

    token = accounts(:bob).password_reset_token
    get edit_password_path(token)
    assert_response :success

    put password_path(token), params: { password: "Brandnew12345", password_confirmation: "Brandnew12345" }
    assert_redirected_to new_session_path
    assert Account.log_in("bob", "Brandnew12345")
  end

  test "an unknown email gets the same answer and no email" do
    assert_no_enqueued_emails do
      post passwords_path, params: { email: "nobody@example.com" }
    end
    assert_redirected_to new_session_path
  end

  test "a bad link is turned away" do
    get edit_password_path("nonsense")
    assert_redirected_to new_password_path
  end

  test "a blank new password is turned away, and the link still works" do
    token = accounts(:bob).password_reset_token
    session = accounts(:bob).sessions.create!

    put password_path(token), params: { password: "", password_confirmation: "" }
    assert_redirected_to edit_password_path(token)
    assert Session.exists?(session.id)
    assert_equal accounts(:bob), Account.find_by_password_reset_token(token)
  end
end
