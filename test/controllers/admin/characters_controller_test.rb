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

  test "roster characters get their own section above Retired, and retiring one takes it off the roster" do
    characters(:wren).put_on_roster!
    characters(:moth).retire!
    sign_in_as(accounts(:wellkeeper))

    get admin_characters_path
    assert_select ".admin-characters__roster .admin-characters__roster-table a", text: "Wren"
    assert_select ".admin-characters__retired a", text: "Wren", count: 0
    assert_select ".admin-characters__retired a", text: "Moth"
    assert_operator response.body.index("admin-characters__roster"), :<, response.body.index("admin-characters__retired")

    post retire_admin_character_path(characters(:wren))
    wren = characters(:wren).reload
    assert_not wren.on_roster?
    assert wren.retired?
    assert wren.roster_retired?
    assert_not wren.preparing_for_roster?

    get admin_characters_path
    assert_select ".admin-characters__retired a", text: "Wren"
    assert_select ".admin-characters__roster a", text: "Wren", count: 0

    patch admin_roster_character_path(wren), params: { decision: "open" }
    assert characters(:wren).reload.on_roster?
    assert_not characters(:wren).roster_retired?
  end

  test "characters are split into Approved and New sections that can fold" do
    characters(:moth).update!(status: "draft")
    sign_in_as(accounts(:wellkeeper))
    get admin_characters_path
    assert_select "details.admin-characters__approved[open] a", text: "Wren"
    assert_select "details.admin-characters__new a", text: "Moth"
    assert_select "details.admin-characters__approved a", text: "Moth", count: 0
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
