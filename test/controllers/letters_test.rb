require "test_helper"

class LettersTest < ActionDispatch::IntegrationTest
  test "a character posts a letter to someone; everyone reading sees it as a letter, and it doesn't take a turn" do
    sign_in_as(accounts(:bob))
    assert_no_changes -> { scenes(:duel).reload.current_turn_participant_id } do
      post scene_poses_path(scenes(:duel)), params: { pose: { kind: "letter", letter_style: "letter", letter_to: "Wren", body: "Meet me at dawn." } }
    end
    pose = scenes(:duel).poses.letter.last
    assert_equal "Wren", pose.letter_to

    sign_out
    get scene_path(scenes(:duel))
    assert_select ".pose__letter--letter .pose__letter-to", text: "To Wren,"
    assert_select ".pose__letter--letter .pose__letter-from", text: "Sable"
  end

  test "a text message" do
    sign_in_as(accounts(:alice))
    post scene_poses_path(scenes(:duel)), params: { pose: { kind: "letter", letter_style: "text", body: "where r u" } }
    get scene_path(scenes(:duel))
    assert_select ".pose__letter--text .pose__body", text: "where r u"
  end

  test "only someone in the Chapter can post one" do
    sign_in_as(accounts(:builder))
    assert_no_difference -> { Pose.letter.count } do
      post scene_poses_path(scenes(:duel)), params: { pose: { kind: "letter", body: "Hi" } }
    end
  end
end
