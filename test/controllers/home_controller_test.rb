require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "logged out visitors are sent to log in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "lists the top-level areas and says where the active character is" do
    sign_in_as(accounts(:alice))
    get root_path

    assert_response :success
    assert_select ".board__title", "The World"
    assert_select ".where-now a", "The Commons"
  end

  test "players without characters are asked to make one" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select ".where-now a[href=?]", new_character_path
  end
end
