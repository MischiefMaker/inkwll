require "test_helper"

class PosesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(accounts(:alice))
    accounts(:alice).update!(active_character: characters(:wren))
  end

  test "posting a Passage" do
    assert_difference "scenes(:duel).poses.count" do
      post scene_poses_path(scenes(:duel)), params: { pose: { body: "Wren lunges." } }
    end
    assert_redirected_to scene_path(scenes(:duel))
    assert_equal characters(:wren), Pose.last.character
  end

  test "posting out of turn needs Post anyway" do
    sign_in_as(accounts(:bob))
    accounts(:bob).update!(active_character: characters(:sable))

    assert_no_difference "Pose.count" do
      post scene_poses_path(scenes(:duel)), params: { pose: { body: "Me first!" } }
    end
    assert_difference "Pose.count" do
      post scene_poses_path(scenes(:duel)), params: { pose: { body: "Me first!" }, post_anyway: "1" }
    end
  end

  test "watchers can't post" do
    sign_in_as(accounts(:builder))
    assert_no_difference "Pose.count" do
      post scene_poses_path(scenes(:duel)), params: { pose: { body: "Hi!" } }
    end
  end

  test "editing and removing your own Passage" do
    pose = poses(:duel_one)
    patch scene_pose_path(scenes(:duel), pose), params: { pose: { body: "Wren draws her sword." } }
    assert_equal "Wren draws her sword.", pose.reload.body
    assert pose.edited?

    delete scene_pose_path(scenes(:duel), pose)
    assert pose.reload.removed?

    get scene_path(scenes(:duel))
    assert_select ".pose__body", text: "Passage removed."
  end

  test "you can't edit someone else's Passage" do
    patch scene_pose_path(scenes(:duel), poses(:duel_two)), params: { pose: { body: "Hacked" } }
    assert_response :not_found
    assert_equal "Sable laughs and steps back.", poses(:duel_two).reload.body
  end

  test "posting an OOC line out of turn needs no second click, and the Manuscript leaves it out" do
    sign_in_as(accounts(:bob))
    post scene_poses_path(scenes(:duel)), params: { pose: { body: "Back in five", kind: "ooc" } }
    assert_equal "ooc", scenes(:duel).poses.last.kind

    scenes(:duel).finish!(by: characters(:sable))
    get scene_path(scenes(:duel))
    assert_select ".pose--ooc", count: 0
    get scene_path(scenes(:duel), ooc: 1)
    assert_select ".pose--ooc .pose__body", text: /Back in five/
  end

  test "posting as an NPC" do
    post scene_poses_path(scenes(:duel)), params: { pose: { body: "The squire runs off.", kind: "npc", npc_name: "Squire" } }
    get scene_path(scenes(:duel))
    assert_select ".pose--npc .pose__name", text: "Squire"
  end

  test "a roll can't be removed or edited, even by asking directly" do
    roll = scenes(:duel).poses.create!(character: characters(:wren), kind: "roll", body: "Wren rolls.", sequence: 99)
    delete scene_pose_path(scenes(:duel), roll)
    assert_response :not_found
    assert_not roll.reload.removed?
  end
end
