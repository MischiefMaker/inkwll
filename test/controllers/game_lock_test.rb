require "test_helper"

class GameLockTest < ActionDispatch::IntegrationTest
  def lock!
    GameSetting.current.update!(locked: true)
  end

  test "a Wellkeeper locks and unlocks the game from the admin page" do
    sign_in_as(accounts(:wellkeeper))
    get admin_root_path
    assert_select "form[action='#{admin_game_lock_path}'] .button--danger"
    post admin_game_lock_path
    assert_redirected_to admin_root_path
    assert GameSetting.current.locked?
    get admin_root_path
    assert_select ".admin-lock--locked"
    assert_select ".game-lock-banner"
    delete admin_game_lock_path
    assert_not GameSetting.current.locked?
  end

  test "a Scribe and a player are turned away from locking" do
    sign_in_as(accounts(:scribe))
    post admin_game_lock_path
    assert_not GameSetting.current.locked?
    get admin_root_path
    assert_select ".admin-lock", count: 0
    delete session_path
    sign_in_as(accounts(:alice))
    post admin_game_lock_path
    assert_not GameSetting.current.locked?
  end

  test "guests see the locked page" do
    lock!
    get root_path
    assert_response :service_unavailable
    assert_select ".game-locked"
    get rooms_path
    assert_response :service_unavailable
  end

  test "players see the locked page and can log out" do
    lock!
    sign_in_as(accounts(:alice))
    get root_path
    assert_response :service_unavailable
    assert_select ".game-locked form[action='#{session_path}']"
  end

  test "staff can still browse and see the banner" do
    lock!
    sign_in_as(accounts(:scribe))
    get root_path
    assert_response :success
    assert_select ".game-lock-banner"
  end

  test "the log in page still works while locked" do
    lock!
    get new_session_path
    assert_response :success
  end
end
