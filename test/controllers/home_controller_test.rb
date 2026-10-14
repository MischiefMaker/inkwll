require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "logged out visitors are sent to log in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "shows top-level areas as banners with the areas inside as boards" do
    sign_in_as(accounts(:alice))
    get root_path

    assert_response :success
    assert_select ".category__title", "The World"
    assert_select ".board-row__title > a", text: "Castle"
    assert_select ".where-now a", "The Commons"
  end

  test "the arrow beside an area lists shortcuts to its settings" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".shortcuts a", text: "Garden"
  end

  test "players without characters are asked to make one" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select ".where-now a[href=?]", new_character_path
  end
end
