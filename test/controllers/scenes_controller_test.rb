require "test_helper"

class ScenesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "a Setting lists its Chapters and offers to start one there" do
    get room_path(rooms(:commons))

    assert_select ".scene-list__title", text: "Duel at Dawn"
    assert_select ".scene-list__title", text: "A Quiet Word", count: 0
    assert_select "summary", text: "Start a chapter here"
  end

  test "no start form in a Setting the character isn't in" do
    get room_path(rooms(:garden))
    assert_select "summary", text: "Start a chapter here", count: 0
  end

  test "starting a Chapter puts it where the character stands" do
    assert_difference "Scene.count" do
      post scenes_path, params: { scene: { title: "Market Day", visibility: "private", pose_mode: "free" } }
    end
    scene = Scene.last
    assert_redirected_to scene_path(scene)
    assert_equal rooms(:commons), scene.room
    assert scene.visibility_private?
    assert_equal [ characters(:wren) ], scene.characters
  end

  test "a Chapter shows its Setting, people and Passages, with a box to write in" do
    get scene_path(scenes(:duel))

    assert_select ".scene-setting__name", text: "The Commons"
    assert_select ".pose__name", text: "Wren"
    assert_select ".pose__body", text: /Sable laughs/
    assert_select "#mini-profile-#{characters(:sable).id}"
    assert_select ".composer textarea"
    assert_select ".turn-bar", text: /It's your turn/
  end

  test "anyone can watch an open Chapter, but only invited characters can read a private one" do
    sign_in_as(accounts(:builder))
    accounts(:builder).update!(active_character: characters(:finch))
    get scene_path(scenes(:duel))
    assert_select ".pose__body", minimum: 1
    assert_select ".composer", count: 0
    assert_select "button", text: /Join as/

    sign_in_as(accounts(:bob))
    get scene_path(scenes(:tea))
    assert_select ".pose__body", count: 0
    assert_select "p", text: /Only characters in it, or invited to it, can read it/
  end

  test "hidden Chapters don't exist for anyone else" do
    get scene_path(scenes(:secret))
    assert_response :not_found
  end

  test "opening a Chapter switches to the player's character in it" do
    accounts(:alice).update!(active_character: characters(:moth))
    get scene_path(scenes(:duel))
    assert_equal characters(:wren), accounts(:alice).reload.active_character
  end

  test "characters in a Chapter can change its settings" do
    patch scene_path(scenes(:duel)), params: { scene: { title: "Duel at Dusk", auto_skip: "0", turn_minutes: 10 } }
    assert_redirected_to scene_path(scenes(:duel))
    assert_equal "Duel at Dusk", scenes(:duel).reload.title
    assert_not scenes(:duel).auto_skip?

    sign_in_as(accounts(:builder))
    patch scene_path(scenes(:duel)), params: { scene: { title: "Mine now" } }
    assert_equal "Duel at Dusk", scenes(:duel).reload.title
  end

  test "a long open Chapter shows its latest posts live, and the rest on a whole-Chapter page" do
    scene = scenes(:duel)
    (Scene::LIVE_PASSAGES + 5).times { |n| scene.add_system_line!("Line #{n}.") }
    oldest = scene.poses.first

    get scene_path(scene)
    assert_select "#passages .pose", Scene::LIVE_PASSAGES
    assert_select "##{ActionView::RecordIdentifier.dom_id(oldest)}", count: 0
    assert_select ".passages__earlier a[href=?]", scene_path(scene, all: 1)
    live_streams = css_select("turbo-cable-stream-source").size

    get scene_path(scene, all: 1)
    assert_select "#passages .pose", scene.reload.last_sequence
    assert_select "turbo-cable-stream-source", count: live_streams - 1
    assert_select ".composer", count: 0
  end

  test "editing an old Passage returns to the whole-Chapter page" do
    scene = scenes(:duel)
    pose = poses(:duel_one)
    Scene::LIVE_PASSAGES.times { |n| scene.add_system_line!("Line #{n}.") }

    patch scene_pose_path(scene, pose), params: { pose: { body: "Wren draws." } }
    assert_redirected_to scene_path(scene, anchor: "pose_#{pose.id}", all: "1")
  end
end
