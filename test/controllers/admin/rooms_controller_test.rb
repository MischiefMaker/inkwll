require "test_helper"

class Admin::RoomsControllerTest < ActionDispatch::IntegrationTest
  test "players who aren't staff are turned away" do
    sign_in_as(accounts(:alice))
    get new_admin_room_path
    assert_redirected_to root_path
  end

  test "staff can create a room and add an exit" do
    sign_in_as(accounts(:staff))

    post admin_rooms_path, params: { room: { name: "Cellar" } }
    cellar = Room.find_by!(name: "Cellar")

    post admin_room_exits_path(cellar), params: { exit: { name: "Up", destination_room_id: rooms(:commons).id } }
    assert_equal rooms(:commons), cellar.exits.find_by!(name: "Up").destination_room
  end
end
