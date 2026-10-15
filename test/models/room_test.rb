require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "only one room is the starting room" do
    rooms(:garden).update!(starting: true)

    assert_equal rooms(:garden), Room.starting
    assert_not rooms(:commons).reload.starting?
  end

  test "a game with no rooms gets a default starting room" do
    Scene.update_all(current_turn_participant_id: nil)
    [ Pose, SceneInvitation, SceneParticipant, Scene ].each(&:delete_all)
    Character.delete_all
    Exit.delete_all
    Room.delete_all

    room = Room.starting
    assert room.starting?
    assert room.area
  end

  test "exit names are unique within a room" do
    duplicate = rooms(:commons).exits.new(name: "North", destination_room: rooms(:garden))
    assert_not duplicate.valid?
  end

  test "The Prologue becomes the starting Setting, with Paths into each Area" do
    prologue = Room.create_prologue!
    assert_equal prologue, Room.starting
    assert_equal "Out of Character", prologue.area.name
    assert_includes prologue.exits.map(&:destination_room), areas(:world).entrance
    assert_equal prologue, Room.create_prologue!, "making it twice finds the first one"

    character = accounts(:alice).characters.create!(name: "Newcomer")
    assert_equal prologue, character.room
  end
end
