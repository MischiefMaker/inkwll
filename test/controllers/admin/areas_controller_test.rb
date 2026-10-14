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
end
