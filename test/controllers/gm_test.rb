require "test_helper"

class GmTest < ActionDispatch::IntegrationTest
  test "staff switch to GM, start a Chapter as Storyteller, and stay out of Where and Here" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select "button.switcher__gm"

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

  test "Writing as offers GM to Storytellers, warns before joining as GM, and then switches to it" do
    accounts(:alice).update!(storyteller: true)
    accounts(:alice).update!(active_character: characters(:wren))
    sign_in_as(accounts(:alice))
    scene = scenes(:duel)

    get scene_path(scene)
    assert_select ".writing-as__form option", text: /GM \(.*\) \(not in this chapter\)/i
    assert_equal 0, accounts(:alice).characters.where(gm: true).count, "looking doesn't make the GM stand-in"

    patch scene_writing_as_path(scene), params: { character_id: "gm" }
    assert_redirected_to scene_path(scene, join: "gm")
    get scene_path(scene, join: "gm")
    assert_select ".writing-as__warning", text: /GM isn't in this chapter/i

    post scene_participation_path(scene, character_id: "gm")
    gm = accounts(:alice).reload.active_character
    assert gm.gm?
    assert scene.reload.participant_for(gm).storyteller?

    patch scene_writing_as_path(scene), params: { character_id: characters(:wren).id }
    assert_equal characters(:wren), accounts(:alice).reload.active_character
    patch scene_writing_as_path(scene), params: { character_id: "gm" }
    assert_redirected_to scene_path(scene)
    assert accounts(:alice).reload.active_character.gm?
  end

  test "players without the Storyteller flag can't write as GM" do
    accounts(:alice).update!(active_character: characters(:wren))
    sign_in_as(accounts(:alice))
    get scene_path(scenes(:duel))
    assert_select ".writing-as__form option", text: /GM/, count: 0
    patch scene_writing_as_path(scenes(:duel)), params: { character_id: "gm" }
    assert_response :not_found
    post scene_participation_path(scenes(:duel), character_id: "gm")
    assert_response :not_found
  end

  test "players don't get the GM option" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select "button.switcher__gm", count: 0
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
