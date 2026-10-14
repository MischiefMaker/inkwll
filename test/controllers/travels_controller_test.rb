require "test_helper"

class TravelsControllerTest < ActionDispatch::IntegrationTest
  test "travel moves the active character straight to a setting" do
    sign_in_as(accounts(:alice))

    post room_travel_path(rooms(:garden))

    assert_equal rooms(:garden), characters(:wren).reload.room
    assert_redirected_to room_path(rooms(:garden))
  end

  test "Setting pages seen from afar don't offer a jump there; players walk" do
    sign_in_as(accounts(:alice))
    get room_path(rooms(:garden))
    assert_select ".from-afar"
    assert_select "button", text: "Travel here", count: 0
  end
end
