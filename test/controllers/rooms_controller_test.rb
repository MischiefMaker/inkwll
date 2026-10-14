require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = accounts(:alice)
    sign_in_as(@alice)
  end

  test "shows the room, its exits and who is here" do
    get room_path(rooms(:commons))

    assert_response :success
    assert_select "h1", "The Commons"
    assert_select "button.exit-link", "North"
    assert_select "a", "Sable"
  end

  test "exits can't be clicked when the active character is elsewhere" do
    get room_path(rooms(:garden))
    assert_select "button.exit-link", count: 0
  end

  test "remembers the active character for the room" do
    get room_path(rooms(:commons))
    assert_equal characters(:wren), @alice.remembered_character_for(rooms(:commons))
  end

  test "switches back to the character last used in this room" do
    @alice.remember_character(characters(:moth), rooms(:hall))

    get room_path(rooms(:hall))

    assert_equal characters(:moth), @alice.reload.active_character
  end

  test "does not switch to a remembered character who has since left" do
    @alice.remember_character(characters(:moth), rooms(:garden))

    get room_path(rooms(:garden))

    assert_equal characters(:wren), @alice.reload.active_character
  end
end
