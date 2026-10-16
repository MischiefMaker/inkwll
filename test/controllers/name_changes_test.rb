require "test_helper"

class NameChangesTest < ActionDispatch::IntegrationTest
  test "a player renames themselves and staff can see it in the log" do
    sign_in_as(accounts(:alice))
    assert_difference "NameChange.count" do
      patch player_profile_path, params: { account: { display_name: "Alicia" } }
    end
    change = NameChange.last
    assert_equal "Alicia", accounts(:alice).reload.display_name
    assert_equal "Alicia", change.new_name
    assert_equal accounts(:alice), change.changed_by

    sign_in_as(accounts(:scribe))
    get admin_name_changes_path
    assert_response :success
    assert_select ".name-changes__row--player", text: /Alicia/
  end

  test "saving a player profile without renaming logs nothing" do
    sign_in_as(accounts(:alice))
    assert_no_difference "NameChange.count" do
      patch player_profile_path, params: { account: { about_me: "Hello." } }
    end
  end

  test "a character can be renamed by its player until it is approved, with a log" do
    draft = accounts(:alice).characters.create!(name: "Draftling", status: "draft")
    sign_in_as(accounts(:alice))
    assert_difference "NameChange.count" do
      patch character_path(draft), params: { character: { name: "Draftina" } }
    end
    assert_equal "Draftina", draft.reload.name
    assert_equal [ "Draftling", "Draftina" ], NameChange.last.then { |c| [ c.old_name, c.new_name ] }
  end

  test "once approved only staff can rename a character" do
    wren = characters(:wren)
    sign_in_as(accounts(:alice))
    assert_no_difference "NameChange.count" do
      patch character_path(wren), params: { character: { name: "Wrenny" } }
    end
    assert_equal "Wren", wren.reload.name
    get edit_character_path(wren)
    assert_select "input[name='character[name]']", count: 0
    assert wren.renamable_by?(accounts(:scribe))
  end

  test "players can't see the name change log" do
    sign_in_as(accounts(:alice))
    get admin_name_changes_path
    assert_redirected_to root_path
  end
end
