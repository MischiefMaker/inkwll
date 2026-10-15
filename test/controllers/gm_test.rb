require "test_helper"

class GmTest < ActionDispatch::IntegrationTest
  test "staff switch to GM, start a Chapter as Storyteller, and stay out of Where and Here" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select "option.switcher__gm"

    patch active_character_path, params: { character_id: "gm" }
    gm = accounts(:scribe).reload.active_character
    assert gm.gm?
    assert_equal accounts(:scribe).display_name, gm.name

    room = rooms(:commons)
    post room_travel_path(room)
    post scenes_path, params: { scene: { title: "The storm", visibility: "joinable", pose_mode: Scene.pose_modes.keys.first } }
    scene = Scene.find_by!(title: "The storm")
    assert scene.participant_for(gm).storyteller?

    get room_path(room)
    assert_select ".room-here a[href=?]", character_path(gm), count: 0
    get where_path
    assert_select "a[href=?]", character_path(gm), count: 0
    get directory_path
    assert_select "a[href=?]", character_path(gm), count: 0
  end

  test "players don't get the GM option" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select "option.switcher__gm", count: 0
    patch active_character_path, params: { character_id: "gm" }
    assert_not accounts(:alice).reload.active_character&.gm?
    assert_not accounts(:alice).characters.exists?(gm: true)
  end
end
