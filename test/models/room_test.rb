require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "only one room is the starting room" do
    rooms(:garden).update!(starting: true)

    assert_equal rooms(:garden), Room.starting
    assert_not rooms(:commons).reload.starting?
  end

  test "exit names are unique within a room" do
    duplicate = rooms(:commons).exits.new(name: "North", destination_room: rooms(:garden))
    assert_not duplicate.valid?
  end
end
