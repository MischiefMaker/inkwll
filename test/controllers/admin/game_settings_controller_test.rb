require "test_helper"

class Admin::GameSettingsControllerTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper can make email optional" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_game_settings_path, params: { game_setting: { email_required: "0", approval_required: "1" } }
    assert_not GameSetting.current.email_required?
  end

  test "a Scribe can't change game settings" do
    sign_in_as(accounts(:scribe))
    get edit_admin_game_settings_path
    assert_redirected_to root_path
  end
end
