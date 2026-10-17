require "test_helper"

class MutterTest < ActionDispatch::IntegrationTest
  setup do
    characters(:moth).update!(room: scenes(:duel).room)
    scenes(:duel).join!(characters(:moth))
  end

  test "the one muttered to hears it all; others only catch a few words" do
    sign_in_as(accounts(:alice))
    post scene_poses_path(scenes(:duel)), params: { pose: { kind: "mutter", to: characters(:sable).id, body: "The key is hidden under the third stone by the well" } }
    pose = scenes(:duel).poses.mutter.last
    assert_not_nil pose
    assert_match "...", pose.overheard_body
    assert_not_equal pose.body, pose.overheard_body

    sign_in_as(accounts(:bob))
    get scene_path(scenes(:duel))
    assert_select ".pose--mutter .pose__body", text: /The key is hidden under the third stone/

    sign_in_as(accounts(:builder))
    get scene_path(scenes(:duel))
    assert_select ".pose--mutter .pose__body--overheard"
    assert_select ".pose--mutter .pose__body", text: /The key is hidden under the third stone/, count: 0
  end

  test "it doesn't take a turn" do
    sign_in_as(accounts(:alice))
    assert_no_changes -> { scenes(:duel).reload.current_turn_participant_id } do
      post scene_poses_path(scenes(:duel)), params: { pose: { kind: "mutter", to: characters(:sable).id, body: "psst" } }
    end
  end

  test "you can only mutter to someone in the Chapter" do
    sign_in_as(accounts(:alice))
    assert_no_difference -> { Pose.mutter.count } do
      post scene_poses_path(scenes(:duel)), params: { pose: { kind: "mutter", to: characters(:lark).id, body: "psst" } }
    end
  end

  test "emails to others carry only the overheard words" do
    pose = scenes(:duel).post!(characters(:wren), "The key is hidden under the third stone by the well", kind: "mutter", to: characters(:sable).id)
    assert_equal pose.overheard_body, pose.body_for(accounts(:builder))
    assert_equal pose.body, pose.body_for(accounts(:bob))
  end
end
