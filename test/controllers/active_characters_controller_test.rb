require "test_helper"

class ActiveCharactersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "switching goes to the new character's room" do
    patch active_character_path, params: { character_id: characters(:moth).id }

    assert_redirected_to room_path(rooms(:hall))
    assert_equal characters(:moth), accounts(:alice).reload.active_character
  end

  test "cannot switch to another player's character" do
    patch active_character_path, params: { character_id: characters(:sable).id }

    assert_response :not_found
    assert_equal characters(:wren), accounts(:alice).reload.active_character
  end
end
