require "test_helper"

class MovementsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "clicking an exit moves the active character" do
    post exit_movement_path(exits(:commons_north))

    assert_redirected_to room_path(rooms(:hall))
    assert_equal rooms(:hall), characters(:wren).reload.room
  end

  test "cannot use an exit in a different room" do
    post exit_movement_path(exits(:hall_south))

    assert_equal rooms(:commons), characters(:wren).reload.room
    assert_equal "Wren isn't in the right setting to use that path.", flash[:alert]
  end
end
