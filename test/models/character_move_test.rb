require "test_helper"

class CharacterMoveTest < ActiveSupport::TestCase
  test "moving adds a line to the Chapters in both Settings" do
    tea = scenes(:tea)
    tea.update_columns(last_pose_at: 1.minute.ago)

    characters(:sable).update!(room: rooms(:hall))

    assert_equal "Sable leaves for North Hall.", scenes(:duel).poses.last.body
    assert_equal "Sable arrives from The Commons.", tea.poses.last.body
  end

  test "idle Chapters don't get arrival lines" do
    scenes(:duel).update_columns(last_pose_at: 8.days.ago, created_at: 8.days.ago)
    assert_no_difference "scenes(:duel).poses.count" do
      characters(:wren).update!(room: rooms(:garden))
    end
  end
end
