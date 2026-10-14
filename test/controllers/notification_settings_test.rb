require "test_helper"

class NotificationSettingsTest < ActionDispatch::IntegrationTest
  test "a player changes their notification settings" do
    sign_in_as(accounts(:bob))
    get edit_notification_settings_path
    assert_response :success

    patch notification_settings_path, params: { account: { email_notifications: "after_days", email_after_days: 5,
      email_only_my_turn: "1", browser_notifications: "my_turn", browser_notify_minutes: 10 } }
    assert_redirected_to edit_notification_settings_path
    bob = accounts(:bob).reload
    assert_equal [ "after_days", 5, true, "my_turn" ], [ bob.email_notifications, bob.email_after_days, bob.email_only_my_turn, bob.browser_notifications ]
  end

  test "emails need an email address" do
    sign_in_as(accounts(:bob))
    patch notification_settings_path, params: { account: { email: "", email_notifications: "every_time" } }
    assert_response :unprocessable_entity
  end

  test "the stop-these-emails link works without logging in" do
    accounts(:bob).update!(email_notifications: "every_time")
    token = accounts(:bob).generate_token_for(:unsubscribe)

    get unsubscribe_path(token)
    assert_response :success
    assert_equal "every_time", accounts(:bob).reload.email_notifications

    post unsubscribe_path(token)
    assert_response :success
    assert_equal "off", accounts(:bob).reload.email_notifications
  end

  test "a bad stop-these-emails link does nothing" do
    post unsubscribe_path("nonsense")
    assert_response :not_found
  end
end
