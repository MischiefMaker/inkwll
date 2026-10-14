require "test_helper"

class SavedPlacesTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "saving a Setting, seeing it in My places, and removing it" do
    room = rooms(:hall)
    post room_saved_place_path(room)
    get saved_places_path
    assert_select ".my-places__link", text: room.name

    delete room_saved_place_path(room)
    get saved_places_path
    assert_select ".my-places__link", count: 0
  end

  test "the Where list shows how long since a character was active" do
    characters(:wren).update_column(:last_active_at, 3.hours.ago)
    get where_path
    assert_select ".where-room__idle", text: "(idle 3h)"
  end

  test "a Chapter's Setting box lists the Paths when you're standing there" do
    get scene_path(scenes(:duel))
    assert_select ".scene-setting__paths .exit-link"
  end
end
