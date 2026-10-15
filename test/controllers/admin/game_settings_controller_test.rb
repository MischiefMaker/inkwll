require "test_helper"

class Admin::GameSettingsControllerTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper can make email optional" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_game_settings_path, params: { game_setting: { email_required: "0", approval_required: "1" } }
    assert_not GameSetting.current.email_required?
  end

  test "the game icon defaults to the favicon, can be uploaded, and shows in the top bar and front page" do
    get root_path
    assert_select "header .game-icon--small.game-icon--default"
    assert_select ".game-intro__name .game-icon--large.game-icon--default"

    sign_in_as(accounts(:wellkeeper))
    patch admin_game_settings_path, params: { game_setting: { icon: fixture_file_upload("pixel.png", "image/png") } }
    assert GameSetting.current.icon.attached?
    get root_path
    assert_select ".site-header__title .game-icon--small", count: 1
    assert_select ".game-icon--default", count: 0

    patch admin_game_settings_path, params: { game_setting: { remove_icon: "1" } }
    assert_not GameSetting.current.reload.icon.attached?
  end

  test "the game icon has to be a picture" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_game_settings_path, params: { game_setting: { icon: fixture_file_upload("not-a-picture.txt", "text/plain") } }
    assert_response :unprocessable_entity
    assert_not GameSetting.current.icon.attached?
  end

  test "a Scribe can't change game settings" do
    sign_in_as(accounts(:scribe))
    get edit_admin_game_settings_path
    assert_redirected_to root_path
  end
end
