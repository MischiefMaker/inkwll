require "test_helper"

class GuidesTest < ActionDispatch::IntegrationTest
  test "a guest can read How it works and is offered Sign up" do
    get how_it_works_path, headers: { "User-Agent" => "Mozilla/5.0 Firefox/130.0" }
    assert_response :success
    assert_select ".guide .page-title", "How it works"
    assert_select ".guide__section--places", /Settings/
    assert_select ".guide__join a[href=?]", new_registration_path
  end

  test "players find it in the Menu" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".menu__items a.menu__guide[href=?]", how_it_works_path
    get how_it_works_path
    assert_response :success
    assert_select ".guide__join", 0
  end
end
