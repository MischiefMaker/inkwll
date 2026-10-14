require "test_helper"

class Admin::NumberedRoomsControllerTest < ActionDispatch::IntegrationTest
  test "players who aren't staff are turned away" do
    sign_in_as(accounts(:alice))
    assert_no_difference "Room.count" do
      post admin_room_numbered_rooms_path(rooms(:commons)), params: { lines: "100 Jaxon Marley" }
    end
    assert_redirected_to root_path
  end

  test "makes a numbered room per line with a Path in and a way back out" do
    rooms(:hall).update!(kind: "apartments")
    sign_in_as(accounts(:builder))

    assert_difference [ "Room.count" ], 3 do
      assert_difference "Exit.count", 6 do
        post admin_room_numbered_rooms_path(rooms(:hall)), params: { lines: "100 Jaxon Marley\n\n101 - Nestor Nash\n203", return_name: "" }
      end
    end
    assert_redirected_to edit_admin_room_path(rooms(:hall))

    door = rooms(:hall).exits.find_by!(number: "100")
    assert_equal "Jaxon Marley", door.name
    assert_equal "Apartment 100", door.destination_room.name
    assert_equal rooms(:hall).area, door.destination_room.area
    assert_equal "Nestor Nash", rooms(:hall).exits.find_by!(number: "101").name
    assert_equal "Apartment 203", rooms(:hall).exits.find_by!(number: "203").name
    assert_equal [ "Out" ], door.destination_room.exits.map(&:name)
    assert_equal rooms(:hall), door.destination_room.exits.first.destination_room
  end

  test "saves nothing when a line clashes with an existing door" do
    Exit.create!(source_room: rooms(:hall), destination_room: rooms(:garden), number: "101", name: "Gardener")
    sign_in_as(accounts(:builder))

    assert_no_difference [ "Room.count", "Exit.count" ] do
      post admin_room_numbered_rooms_path(rooms(:hall)), params: { lines: "100 Jaxon Marley\n101 Nestor Nash" }
    end
    assert_match "101", flash[:alert]
  end

  test "a builder can set a Setting's type and give a Path a number" do
    sign_in_as(accounts(:builder))
    patch admin_room_path(rooms(:hall)), params: { room: { kind: "hotel" } }
    assert_equal "hotel", rooms(:hall).reload.kind

    post admin_room_exits_path(rooms(:hall)), params: { exit: { number: "12", name: "Bridal suite", destination_room_id: rooms(:garden).id } }
    assert_equal "12", rooms(:hall).exits.find_by!(name: "Bridal suite").number
  end
end
