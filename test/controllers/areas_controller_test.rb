require "test_helper"

class AreasControllerTest < ActionDispatch::IntegrationTest
  test "shows the settings and areas inside an area" do
    sign_in_as(accounts(:alice))
    get area_path(areas(:world))

    assert_response :success
    assert_select "a", "The Commons"
    assert_select ".board__title a", "Castle"
  end

  test "shows the way back up" do
    sign_in_as(accounts(:alice))
    get area_path(areas(:castle))
    assert_select ".breadcrumbs a", "The World"
  end
end
