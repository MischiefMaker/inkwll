require "test_helper"

class Admin::RoomsControllerTest < ActionDispatch::IntegrationTest
  test "players who aren't staff are turned away" do
    sign_in_as(accounts(:alice))
    get new_admin_room_path
    assert_redirected_to root_path
  end

  test "a Build Page can create a room and add an exit" do
    sign_in_as(accounts(:builder))

    post admin_rooms_path, params: { room: { name: "Cellar", area_id: areas(:world).id } }
    cellar = Room.find_by!(name: "Cellar")

    post admin_room_exits_path(cellar), params: { exit: { name: "Up", destination_room_id: rooms(:commons).id } }
    assert_equal rooms(:commons), cellar.exits.find_by!(name: "Up").destination_room
    assert_empty rooms(:commons).exits.where(destination_room: cellar)
  end

  test "adding an exit can add the return exit too" do
    sign_in_as(accounts(:builder))

    post admin_room_exits_path(rooms(:garden)), params: { exit: { name: "Gate", destination_room_id: rooms(:hall).id, return_name: "Garden gate" } }

    assert_equal rooms(:hall), rooms(:garden).exits.find_by!(name: "Gate").destination_room
    assert_equal rooms(:garden), rooms(:hall).exits.find_by!(name: "Garden gate").destination_room
  end

  test "if the return exit can't be made, neither exit is added" do
    sign_in_as(accounts(:builder))

    assert_no_difference "Exit.count" do
      post admin_room_exits_path(rooms(:garden)), params: { exit: { name: "Back", destination_room_id: rooms(:commons).id, return_name: "North" } }
    end
    assert_match "Return", flash[:alert]
  end

  test "rooms can have an image" do
    sign_in_as(accounts(:builder))
    image = fixture_file_upload("pixel.png", "image/png")

    patch admin_room_path(rooms(:hall)), params: { room: { image: image } }

    assert rooms(:hall).reload.image.attached?
    get room_path(rooms(:hall))
    assert_select ".description-image img"
  end
end
