require "test_helper"

class ArchivesControllerTest < ActionDispatch::IntegrationTest
  setup do
    scenes(:duel).finish!(by: characters(:wren))
    scenes(:secret).finish!(by: characters(:sable))
    sign_in_as(accounts(:alice))
  end

  test "lists finished Chapters the player may read" do
    get archives_path
    assert_select ".manuscript__title a", text: "Duel at Dawn"
    assert_select ".manuscript__title a", text: "A Quiet Word", count: 0
  end

  test "filters by Setting and by character" do
    get archives_path(room_id: rooms(:hall).id)
    assert_select ".manuscript", count: 0

    get archives_path(character_id: characters(:wren).id)
    assert_select ".manuscript__title a", text: "Duel at Dawn"
  end

  test "Settings and characters link to their Manuscripts" do
    get room_path(rooms(:commons))
    assert_select "a", text: /1 finished chapter in the Bookshelf/

    get character_path(characters(:wren), tab: "logs")
    assert_select ".manuscript__title a", text: "Duel at Dawn"
  end

  test "a finished Chapter offers undo, and no writing box" do
    get scene_path(scenes(:duel))
    assert_select "button", text: "Undo finish"
    assert_select ".composer", count: 0
  end
end
