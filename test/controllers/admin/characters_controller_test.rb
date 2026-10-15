require "test_helper"

class Admin::CharactersControllerTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper retires a character instead of deleting it" do
    sign_in_as(accounts(:wellkeeper))

    assert_no_difference "Character.count" do
      post retire_admin_character_path(characters(:moth))
    end
    moth = characters(:moth).reload
    assert moth.retired?
    assert_not moth.can_play?
    assert_not_includes moth.room.characters, moth

    post unretire_admin_character_path(moth)
    assert_not moth.reload.retired?
  end

  test "retired characters are listed in their own section at the bottom" do
    characters(:moth).retire!
    sign_in_as(accounts(:wellkeeper))
    get admin_characters_path
    assert_select ".admin-characters__active a", text: "Wren"
    assert_select ".admin-characters__active a", text: "Moth", count: 0
    assert_select ".admin-characters__retired .admin-characters__retired-table a", text: "Moth"
  end

  test "a Scribe can't retire characters" do
    sign_in_as(accounts(:scribe))
    post retire_admin_character_path(characters(:moth))
    assert_redirected_to root_path
    assert_not characters(:moth).reload.retired?
  end

  test "an account with characters can't be deleted" do
    assert_not accounts(:alice).destroy
    assert Character.exists?(characters(:wren).id)
  end
end
