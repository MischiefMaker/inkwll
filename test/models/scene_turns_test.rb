require "test_helper"

class SceneTurnsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @scene = scenes(:duel)
    @wren = scene_participants(:duel_wren)
    @sable = scene_participants(:duel_sable)
  end

  test "posting on your turn passes the turn to the next character" do
    @scene.post!(characters(:wren), "Wren lunges.")
    assert @scene.reload.turn_of?(@sable)

    @scene.post!(characters(:sable), "Sable parries.")
    assert @scene.reload.turn_of?(@wren)
  end

  test "posting out of turn is allowed but doesn't move the turn" do
    assert @scene.out_of_turn?(@sable)
    @scene.post!(characters(:sable), "Sable gets impatient.")
    assert @scene.reload.turn_of?(@wren)
  end

  test "the first pose in a new scene starts the turn order" do
    scene = Scene.start!(character: characters(:wren), title: "Fresh")
    scene.join!(characters(:sable))
    assert_nil scene.current_turn_participant

    scene.post!(characters(:sable), "Sable opens.")
    assert scene.reload.turn_of?(scene.participant_for(characters(:wren)))
  end

  test "passing moves the turn on, but only on your own turn" do
    assert_not @scene.pass!(@sable)
    assert @scene.pass!(@wren)
    assert @scene.reload.turn_of?(@sable)
    assert_equal "Wren passes.", @scene.poses.last.body
  end

  test "only a storyteller can skip a turn" do
    assert_not @scene.skip!(by: @sable)

    accounts(:bob).update!(storyteller: true)
    @sable.update!(role: "storyteller")
    assert @scene.skip!(by: @sable)
    assert @scene.reload.turn_of?(@sable)
  end

  test "leaving on your turn passes it on" do
    @scene.leave!(characters(:wren))
    assert @scene.reload.turn_of?(@sable.reload)
  end

  test "free-for-all has no turns" do
    @scene.update!(pose_mode: "free")
    assert_not @scene.turn_based?
    assert_not @scene.out_of_turn?(@sable)
  end

  test "the 3-pose rule needs four characters, and works like turns until then" do
    scene = Scene.start!(character: characters(:wren), title: "Crowded", pose_mode: "three_pose")
    scene.join!(characters(:sable))
    assert scene.turn_based?

    scene.join!(characters(:finch))
    scene.join!(characters(:lark))
    assert_equal "three_pose", scene.reload.effective_pose_mode
    wren = scene.participant_for(characters(:wren))

    scene.post!(characters(:wren), "One.")
    assert_raises(ArgumentError) { scene.post!(characters(:wren), "Again!") }

    scene.post!(characters(:sable), "Two.")
    scene.post!(characters(:finch), "Three.")
    assert_equal 1, scene.poses_to_wait_for(wren)
    scene.post!(characters(:lark), "Four.")
    assert_nothing_raised { scene.post!(characters(:wren), "Back again.") }
  end

  test "auto-skip warns after the turn time, then skips after two more minutes" do
    assert_enqueued_with(job: TurnTimerJob) { @scene.pass!(@wren) }
    @scene.reload
    token = @scene.turn_token
    assert @scene.turn_of?(@sable)

    travel 5.minutes do
      @scene.run_turn_timer!(token)
      assert @scene.reload.turn_warned_at
      assert @scene.turn_of?(@sable)
    end

    travel 7.minutes do
      @scene.run_turn_timer!(token)
      assert @scene.reload.turn_of?(@wren)
      assert_equal "Sable's turn was skipped.", @scene.poses.last.body
    end
  end

  test "I'm here! restarts the timer, so the old timer does nothing" do
    @scene.pass!(@wren)
    old_token = @scene.reload.turn_token

    travel 5.minutes do
      @scene.run_turn_timer!(old_token)
      assert @scene.still_here!(@sable.reload)
      assert_nil @scene.reload.turn_warned_at
    end

    travel 8.minutes do
      @scene.run_turn_timer!(old_token)
      assert @scene.reload.turn_of?(@sable)
    end
  end

  test "with auto-skip off, no timer runs" do
    @scene.update!(auto_skip: false)
    assert_no_enqueued_jobs(only: TurnTimerJob) { @scene.pass!(@wren) }
  end
end
