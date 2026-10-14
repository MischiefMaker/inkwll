require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "logged out visitors are sent to log in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "goes to the active character's room" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_redirected_to room_path(rooms(:commons))
  end

  test "players without characters are asked to make one" do
    sign_in_as(accounts(:staff))
    get root_path
    assert_redirected_to new_character_path
  end
end
