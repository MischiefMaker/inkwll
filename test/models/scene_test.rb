require "test_helper"

class SceneTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "a new scene starts in the room the character stands in, with them in it" do
    scene = Scene.start!(character: characters(:moth), title: "  Late   Supper ")

    assert_equal rooms(:hall), scene.room
    assert_equal "Late Supper", scene.title
    assert_equal [ characters(:moth) ], scene.characters
    assert scene.participants.first.player?
  end

  test "only Storytellers and staff can start as the storyteller" do
    assert Scene.start!(character: characters(:wren), title: "A", storyteller: true).participants.first.player?
    assert Scene.start!(character: characters(:lark), title: "B", storyteller: true).participants.first.storyteller?
  end

  test "new scenes take the game's auto-skip settings" do
    GameSetting.current.update!(auto_skip: false, turn_minutes: 10)
    scene = Scene.start!(character: characters(:wren), title: "Slow")
    assert_not scene.auto_skip?
    assert_equal 10, scene.turn_minutes
  end

  test "who can see, read and join each kind of scene" do
    bob = accounts(:bob)
    alice = accounts(:alice)

    assert scenes(:duel).readable_by?(accounts(:builder))
    assert scenes(:duel).can_join?(characters(:finch))

    assert scenes(:tea).visible_to?(bob)
    assert_not scenes(:tea).readable_by?(bob)
    assert_not scenes(:tea).can_join?(characters(:sable))

    assert_not scenes(:secret).visible_to?(alice)
    assert scenes(:secret).visible_to?(bob)
    assert_not_includes Scene.visible_to(alice), scenes(:secret)
    assert_includes Scene.visible_to(bob), scenes(:secret)
  end

  test "an invitation lets a character see, read and join a hidden scene" do
    scene = scenes(:secret)
    scene.invitations.create!(character: characters(:wren))

    assert scene.visible_to?(accounts(:alice))
    assert scene.readable_by?(accounts(:alice))
    assert_includes Scene.visible_to(accounts(:alice)), scene

    scene.join!(characters(:wren))
    assert_includes scene.reload.characters, characters(:wren)
    assert_empty scene.invitations
  end

  test "joining and leaving add a line to the scene" do
    scene = scenes(:duel)
    scene.join!(characters(:finch))
    assert_equal "Finch joins the Chapter.", scene.poses.last.body
    assert_equal 3, scene.participants.last.position

    scene.leave!(characters(:finch))
    assert_equal "Finch leaves the Chapter.", scene.poses.reload.last.body
    assert_not_includes scene.reload.characters, characters(:finch)
  end

  test "the server numbers poses in order" do
    scene = scenes(:duel)
    pose = scene.post!(characters(:wren), "Wren lunges.")
    assert_equal 3, pose.sequence
    assert_equal 3, scene.reload.last_sequence
  end

  test "only characters in the scene can post" do
    assert_raises(ArgumentError) { scenes(:duel).post!(characters(:moth), "Hello?") }
  end

  test "editing keeps the original, and removing keeps the text" do
    pose = poses(:duel_one)
    pose.edit!("Wren draws her sword.")
    pose.edit!("Wren draws her rapier.")
    assert_equal "Wren draws her blade.", pose.original_body
    assert pose.edited?

    pose.remove!
    assert pose.removed?
    assert_equal "Wren draws her rapier.", pose.body
  end

  test "a scene is idle after seven days without a pose" do
    scene = scenes(:duel)
    assert_not scene.idle?
    scene.update!(last_pose_at: 8.days.ago)
    assert scene.idle?
  end
end
