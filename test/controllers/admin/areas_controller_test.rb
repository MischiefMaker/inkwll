require "test_helper"

class Admin::AreasControllerTest < ActionDispatch::IntegrationTest
  test "a Build Page can nest an area inside another" do
    sign_in_as(accounts(:builder))

    post admin_areas_path, params: { area: { name: "First Floor", parent_id: areas(:castle).id } }

    floor = Area.find_by!(name: "First Floor")
    assert_equal [ areas(:world), areas(:castle) ], floor.ancestors
  end

  test "an area can't be put inside itself" do
    sign_in_as(accounts(:builder))

    patch admin_area_path(areas(:world)), params: { area: { parent_id: areas(:castle).id } }

    assert_response :unprocessable_entity
    assert_nil areas(:world).reload.parent
  end

  test "a Page without the Build job is turned away" do
    accounts(:builder).update!(job_flags: [ "app" ])
    sign_in_as(accounts(:builder))
    get admin_areas_path
    assert_redirected_to root_path
  end

  test "an area's entrance must be inside it" do
    sign_in_as(accounts(:builder))

    patch admin_area_path(areas(:castle)), params: { area: { entrance_room_id: rooms(:commons).id } }
    assert_response :unprocessable_entity

    patch admin_area_path(areas(:world)), params: { area: { entrance_room_id: rooms(:garden).id } }
    assert_equal rooms(:garden), areas(:world).reload.entrance
  end

  test "the admin menu shows only the links a Page may use" do
    sign_in_as(accounts(:builder))
    get admin_root_path
    assert_select ".admin-menu a", text: "Building"
    assert_select ".admin-menu a", text: "Players and staff", count: 0
    assert_select ".admin-menu__heading", text: "Settings", count: 0
    assert_select "body.is-admin"
  end

  test "an empty Area can be deleted, one with Places or inner Areas can't" do
    sign_in_as(accounts(:scribe))
    empty = Area.create!(name: "Empty Land")
    assert_difference "Area.count", -1 do
      delete admin_area_path(empty)
    end

    full = rooms(:hall).area
    assert_no_difference "Area.count" do
      delete admin_area_path(full)
    end
    assert_redirected_to edit_admin_area_path(full)

    outer = Area.create!(name: "Outer")
    Area.create!(name: "Inner", parent: outer)
    assert_no_difference "Area.count" do
      delete admin_area_path(outer)
    end
  end

  test "an ordinary player can't delete an Area" do
    empty = Area.create!(name: "Empty Land")
    sign_in_as(accounts(:alice))
    assert_no_difference "Area.count" do
      delete admin_area_path(empty)
    end
  end
end
