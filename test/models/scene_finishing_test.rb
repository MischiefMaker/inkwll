require "test_helper"

class SceneFinishingTest < ActiveSupport::TestCase
  setup { @scene = scenes(:duel) }

  test "finishing locks the scene and records who did it" do
    assert @scene.finish!(by: characters(:wren))
    assert @scene.finished?
    assert_equal characters(:wren), @scene.finished_by
    assert_equal "Wren finished this Chapter.", @scene.poses.last.body
    assert_raises(ArgumentError) { @scene.post!(characters(:sable), "Wait!") }
    assert_not @scene.turn_of?(scene_participants(:duel_wren))
  end

  test "players can undo finishing within a day" do
    @scene.finish!(by: characters(:wren))
    assert @scene.reopen!(by: characters(:sable))
    assert_not @scene.reload.finished?

    @scene.finish!(by: characters(:wren))
    travel 25.hours do
      assert_not @scene.reopen!(by: characters(:sable))
      assert @scene.reload.finished?
    end
  end

  test "Chapters nobody posts in for the auto-finish time finish on their own" do
    @scene.update_columns(last_pose_at: 31.days.ago)
    AutoFinishJob.perform_now
    assert @scene.reload.finished?
    assert_nil @scene.finished_by
    assert_match "finished after 30 days", @scene.poses.last.body
    assert_not scenes(:tea).reload.finished?
  end

  test "idle and auto-finish times are game settings" do
    GameSetting.current.update!(idle_days: 2, auto_finish_days: 5)
    @scene.update_columns(last_pose_at: 3.days.ago)
    assert @scene.idle?
    @scene.update_columns(last_pose_at: 6.days.ago)
    assert_includes Scene.abandoned, @scene
  end

  test "a finished private Chapter is public; a finished hidden one isn't" do
    scenes(:tea).finish!(by: characters(:moth))
    assert scenes(:tea).readable_by?(accounts(:bob))

    scenes(:secret).finish!(by: characters(:sable))
    assert_not scenes(:secret).readable_by?(accounts(:alice))
    assert_not_includes Scene.visible_to(accounts(:alice)), scenes(:secret)
  end

  test "a hidden Manuscript becomes public only when every player agrees" do
    scene = scenes(:secret)
    scene.invitations.create!(character: characters(:wren))
    scene.join!(characters(:wren))
    scene.finish!(by: characters(:sable))

    scene.consent_to_public!(scene.participant_for(characters(:sable)))
    assert_nil scene.reload.made_public_at
    scene.consent_to_public!(scene.participant_for(characters(:wren)))
    assert scene.reload.made_public_at
    assert scene.readable_by?(accounts(:builder))
  end

  test "staff who handle reports can read a hidden Chapter only once it's reported" do
    scribe = accounts(:scribe)
    assert_not scenes(:secret).readable_by?(scribe)

    scenes(:secret).reports.create!(account: accounts(:bob), reason: "Something's wrong.")
    assert scenes(:secret).readable_by?(scribe)
    assert_includes Scene.visible_to(scribe), scenes(:secret)
    assert_not scenes(:secret).readable_by?(accounts(:builder))
  end
end
