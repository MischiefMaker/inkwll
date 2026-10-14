require "test_helper"

class PoseKindsTest < ActiveSupport::TestCase
  setup do
    @scene = scenes(:duel)
    @wren = scene_participants(:duel_wren)
    @sable = scene_participants(:duel_sable)
  end

  test "OOC lines don't take a turn or count as unread" do
    @scene.post!(characters(:wren), "brb, phone", kind: "ooc")
    assert @scene.reload.turn_of?(@wren)
    assert_equal 0, @sable.reload.unread_count
  end

  test "an NPC Passage takes the poster's turn and needs a name" do
    assert_raises(ActiveRecord::RecordInvalid) { @scene.post!(characters(:wren), "Hello.", kind: "npc") }
    pose = @scene.post!(characters(:wren), "The innkeeper scowls.", kind: "npc", npc_name: "Innkeeper")
    assert_equal "Innkeeper", pose.display_name
    assert @scene.reload.turn_of?(@sable)
    assert_equal 1, @sable.reload.unread_count
  end

  test "anyone can narrate when there's no storyteller, and it doesn't take a turn" do
    @scene.post!(characters(:sable), "Dawn breaks over the field.", kind: "narration")
    assert @scene.reload.turn_of?(@wren)
  end

  test "with a storyteller, only they can narrate" do
    accounts(:alice).update!(storyteller: true)
    @wren.update!(role: "storyteller")
    assert_raises(ArgumentError) { @scene.post!(characters(:sable), "Thunder.", kind: "narration") }
    assert @scene.post!(characters(:wren), "Thunder.", kind: "narration")
  end

  test "system lines can't be posted by players" do
    assert_raises(ArgumentError) { @scene.post!(characters(:wren), "Fake line.", kind: "system") }
  end
end
