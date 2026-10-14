require "test_helper"

class CharactersControllerTest < ActionDispatch::IntegrationTest
  test "a player's first character becomes active" do
    staff = accounts(:scribe)
    sign_in_as(staff)

    post characters_path, params: { character: { name: "Quill" } }

    assert_equal "Quill", staff.reload.active_character.name
  end

  test "creating another character keeps the current one active" do
    sign_in_as(accounts(:alice))
    post characters_path, params: { character: { name: "Fennel" } }
    assert_equal characters(:wren), accounts(:alice).reload.active_character
  end

  test "cannot edit someone else's character" do
    sign_in_as(accounts(:alice))
    get edit_character_path(characters(:sable))
    assert_response :not_found
  end

  test "can view anyone's character" do
    sign_in_as(accounts(:alice))
    get character_path(characters(:sable))
    assert_response :success
  end
end
