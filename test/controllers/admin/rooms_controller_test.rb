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

  test "rooms can have an icon, short text and a background, and use their area's background otherwise" do
    sign_in_as(accounts(:builder))
    patch admin_room_path(rooms(:hall)), params: { room: { summary: "Echoing stone.", icon: fixture_file_upload("pixel.png", "image/png") } }
    patch admin_area_path(rooms(:hall).area), params: { area: { background: fixture_file_upload("pixel.png", "image/png") } }

    get room_path(rooms(:hall))
    assert_select ".page-title__icon"
    assert_select ".lede", "Echoing stone."
    assert_select "body[style*=?]", "--page-image"

    patch admin_room_path(rooms(:hall)), params: { room: { remove_icon: "1" } }
    assert_not rooms(:hall).reload.icon.attached?
  end

  test "a Path with a direction can add the way back pointing the opposite way" do
    sign_in_as(accounts(:builder))
    post admin_room_exits_path(rooms(:garden)), params: { exit: { direction: "NNW", name: "", destination_room_id: rooms(:hall).id, add_return: "1" } }

    there = rooms(:garden).exits.find_by!(direction: "NNW")
    assert_equal "North-northwest", there.name
    back = rooms(:hall).exits.find_by!(destination_room: rooms(:garden))
    assert_equal "SSE", back.direction
    assert_equal "South-southeast", back.name
  end

  test "the compass shows on a Setting only when the game switches it on" do
    exits(:commons_north).update!(direction: "N")
    sign_in_as(accounts(:alice))
    get room_path(rooms(:commons))
    assert_select ".compass", count: 0
    assert_select ".exit-link .exit-link__direction", "N"

    GameSetting.current.update!(compass_enabled: true)
    get room_path(rooms(:commons))
    assert_select ".compass button.compass__point--n"
  end

  test "a building's way back is Out, and buildings are listed apart from streets" do
    rooms(:hall).update!(kind: "building")
    sign_in_as(accounts(:builder))
    post admin_room_exits_path(rooms(:garden)), params: { exit: { kind: "building", name: "Greenhouse", destination_room_id: rooms(:hall).id, add_return: "1" } }

    back = rooms(:hall).exits.find_by!(destination_room: rooms(:garden))
    assert_equal [ "OUT", "Out", "street" ], [ back.direction, back.name, back.kind ]

    sign_in_as(accounts(:alice))
    get room_path(rooms(:garden))
    assert_select ".room-paths__heading--building", "Buildings"
    assert_select ".exits--building .exit-link", text: "Greenhouse"
  end

  test "a new exit's type is picked from the Setting it leads to, and can be edited" do
    shop = Room.create!(area: rooms(:hall).area, name: "Corner Shop", kind: "building")
    sign_in_as(accounts(:scribe))
    post admin_room_exits_path(rooms(:hall)), params: { exit: { name: "Shop door", kind: "", destination_room_id: shop.id } }
    door = rooms(:hall).exits.find_by!(name: "Shop door")
    assert_equal "building", door.kind
    post admin_room_exits_path(rooms(:hall)), params: { exit: { name: "Lane", kind: "", destination_room_id: rooms(:commons).id } }
    assert_equal "street", rooms(:hall).exits.find_by!(name: "Lane").kind

    get edit_admin_room_exit_path(rooms(:hall), door)
    assert_response :success
    patch admin_room_exit_path(rooms(:hall), door), params: { exit: { name: "Shop entrance", kind: "street" } }
    assert_equal "Shop entrance", door.reload.name
    assert_equal "street", door.kind
    get edit_admin_room_path(rooms(:hall))
    assert_select ".icon-action--edit"
  end

  test "an ordinary player can't edit an exit" do
    door = rooms(:hall).exits.first || Exit.create!(source_room: rooms(:hall), destination_room: rooms(:commons), name: "Lane")
    sign_in_as(accounts(:alice))
    patch admin_room_exit_path(rooms(:hall), door), params: { exit: { name: "Hacked" } }
    assert_not_equal "Hacked", door.reload.name
  end

  test "an empty Setting can be deleted along with its Paths, but not one with Chapters, characters or the starting flag" do
    sign_in_as(accounts(:scribe))
    spare = Room.create!(area: rooms(:hall).area, name: "Spare Room")
    Exit.create!(source_room: rooms(:hall), destination_room: spare, name: "Spare door")
    assert_difference "Room.count", -1 do
      delete admin_room_path(spare)
    end
    assert_nil rooms(:hall).exits.find_by(name: "Spare door")

    busy = scenes(:duel).room
    assert_no_difference "Room.count" do
      delete admin_room_path(busy)
    end
    assert_redirected_to edit_admin_room_path(busy)
    assert_equal busy, Scene.find(scenes(:duel).id).room

    start = Room.starting
    assert_no_difference "Room.count" do
      delete admin_room_path(start)
    end
  end

  test "an ordinary player can't delete a Setting" do
    spare = Room.create!(area: rooms(:hall).area, name: "Spare Room")
    sign_in_as(accounts(:alice))
    assert_no_difference "Room.count" do
      delete admin_room_path(spare)
    end
  end
end
