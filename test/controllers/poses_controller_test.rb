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
end
