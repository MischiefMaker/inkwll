require "test_helper"

class Admin::BulkBuildsControllerTest < ActionDispatch::IntegrationTest
  test "players who aren't staff are turned away" do
    sign_in_as(accounts(:alice))
    get new_admin_bulk_build_path
    assert_redirected_to root_path

    assert_no_difference "Room.count" do
      post admin_bulk_build_path, params: { bulk_build: { area_id: areas(:world).id, rooms: { "1" => { name: "Cellar" } } } }
    end
    assert_redirected_to root_path
  end

  test "a Build Page sees the form" do
    sign_in_as(accounts(:builder))
    get new_admin_bulk_build_path
    assert_response :success
    assert_select ".bulk-build__rooms .bulk-build__room", 2
    assert_select ".bulk-build__paths .bulk-build__path", 1
  end

  test "makes several rooms and the exits between them, skipping empty rows" do
    sign_in_as(accounts(:builder))

    assert_difference "Room.count", 2 do
      post admin_bulk_build_path, params: { bulk_build: {
        area_id: areas(:world).id,
        rooms: { "1" => { name: "Cellar", description: "Damp." }, "2" => { name: "Wine store" }, "3" => { name: "", description: "" } },
        paths: {
          "1" => { from: "new-1", name: "In", to: "new-2", return_name: "Out" },
          "2" => { from: rooms(:hall).id.to_s, name: "Down", to: "new-1", return_name: "" },
          "3" => { from: "", name: "", to: "", return_name: "" }
        }
      } }
    end
    assert_redirected_to admin_areas_path

    cellar = Room.find_by!(name: "Cellar")
    store = Room.find_by!(name: "Wine store")
    assert_equal areas(:world), cellar.area
    assert_equal "Damp.", cellar.description
    assert_equal store, cellar.exits.find_by!(name: "In").destination_room
    assert_equal cellar, store.exits.find_by!(name: "Out").destination_room
    assert_equal cellar, rooms(:hall).exits.find_by!(name: "Down").destination_room
    assert_empty cellar.exits.where(destination_room: rooms(:hall))
  end

  test "if anything can't be made, nothing is saved and the rows are kept" do
    sign_in_as(accounts(:builder))

    assert_no_difference [ "Room.count", "Exit.count" ] do
      post admin_bulk_build_path, params: { bulk_build: {
        area_id: areas(:world).id,
        rooms: { "1" => { name: "Cellar" }, "2" => { name: "Wine store" } },
        paths: { "1" => { from: "new-1", name: "", to: "new-2" } }
      } }
    end
    assert_response :unprocessable_entity
    assert_select ".flash--alert", /Name can't be blank/
    assert_select "input[value='Wine store']"
    assert_select "option[selected][value='new-2']"
  end
end
