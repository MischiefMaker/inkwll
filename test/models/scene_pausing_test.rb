require "test_helper"

class ScenePausingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup { @scene = scenes(:duel) }

  test "pausing stops the turn timer and keeps the game from finishing it" do
    assert @scene.pause!(by: characters(:wren), note: "Back Saturday")
    assert @scene.paused?
    assert_not @scene.auto_skip_running?
    assert_equal "Wren paused this Chapter: Back Saturday.", @scene.poses.last.body

    @scene.update_columns(last_pose_at: 60.days.ago)
    assert_not_includes Scene.abandoned, @scene
  end

  test "a new Passage picks it back up, an OOC line doesn't" do
    @scene.pause!(by: characters(:wren))
    @scene.post!(characters(:sable), "Back soon", kind: "ooc")
    assert @scene.reload.paused?

    @scene.post!(characters(:wren), "Wren lunges.")
    assert_not @scene.reload.paused?
    assert @scene.poses.where(body: "Wren picked this Chapter back up.").exists?
  end

  test "picking it back up by hand" do
    @scene.pause!(by: characters(:wren))
    assert @scene.resume!(by: characters(:sable))
    assert_not @scene.reload.paused?
    assert @scene.auto_skip_running?
  end
end
