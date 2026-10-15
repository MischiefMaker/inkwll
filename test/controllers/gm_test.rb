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

  test "switching to GM and back keeps you on the page you're on" do
    sign_in_as(accounts(:scribe))
    here = room_path(rooms(:commons))
    garden = accounts(:scribe).characters.first
    garden.update!(room: rooms(:commons))
    accounts(:scribe).update!(active_character: garden)

    get here
    patch active_character_path, params: { character_id: "gm" }, headers: { "Referer" => "http://www.example.com#{here}" }
    assert_redirected_to here
    get here
    assert accounts(:scribe).reload.active_character.gm?, "the page doesn't switch back to the character"

    patch active_character_path, params: { character_id: garden.id }, headers: { "Referer" => "http://www.example.com#{here}" }
    assert_redirected_to here
    get here
    assert_equal garden, accounts(:scribe).reload.active_character
  end
end
