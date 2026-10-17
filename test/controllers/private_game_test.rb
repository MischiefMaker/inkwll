require "test_helper"

class PrivateGameTest < ActionDispatch::IntegrationTest
  test "a Private Game sends guests to the log-in page and hides the guest chat" do
    get root_path
    assert_response :success

    GameSetting.current.update!(private_game: true)
    [ root_path, directory_path, archives_path, forum_boards_path, room_path(rooms(:commons)) ].each do |path|
      get path
      assert_redirected_to new_session_path
    end
    get new_session_path
    assert_response :success
    assert_select ".ooc-sidebar", count: 0
    get new_registration_path
    assert_response :success

    sign_in_as(accounts(:alice))
    get root_path
    assert_response :success
  end

  test "new players wait for staff approval when the game asks for it" do
    GameSetting.current.update!(player_approval_required: true)
    post registration_path, params: { account: { display_name: "Newcomer", email: "new@example.com", password: "Password123", password_confirmation: "Password123" } }
    newcomer = Account.find_by!(display_name: "Newcomer")
    assert newcomer.awaiting_approval?
    assert_redirected_to account_waiting_path
    follow_redirect!
    assert_select ".account-waiting"

    get new_character_path
    assert_redirected_to account_waiting_path
    post characters_path, params: { character: { name: "Sneaky" } }
    assert_not Character.exists?(name: "Sneaky")
    assert_equal 1, StaffWaiting.count(accounts(:scribe), :players)

    sign_in_as(accounts(:alice))
    patch admin_account_approval_path(newcomer)
    assert newcomer.reload.awaiting_approval?

    sign_in_as(accounts(:scribe))
    get admin_accounts_path
    assert_select ".account-approvals__item", text: /Newcomer/
    patch admin_account_approval_path(newcomer)
    assert_not newcomer.reload.awaiting_approval?

    sign_in_as(newcomer)
    get new_character_path
    assert_response :success
  end

  test "staff can turn a new player away, which archives them" do
    GameSetting.current.update!(player_approval_required: true)
    newcomer = Account.create!(display_name: "Drifter", email: "d@example.com", password: "Password123", awaiting_approval: true)
    sign_in_as(accounts(:scribe))
    delete admin_account_approval_path(newcomer)
    assert newcomer.reload.archived?
  end

  test "without the setting, new players start straight away" do
    post registration_path, params: { account: { display_name: "Quick", email: "q@example.com", password: "Password123", password_confirmation: "Password123" } }
    assert_redirected_to new_character_path
    assert_not Account.find_by!(display_name: "Quick").awaiting_approval?
  end
end
