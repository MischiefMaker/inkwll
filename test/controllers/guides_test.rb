require "test_helper"

class GuidesTest < ActionDispatch::IntegrationTest
  test "a guest can read Getting started and is offered Sign up" do
    get getting_started_path, headers: { "User-Agent" => "Mozilla/5.0 Firefox/130.0" }
    assert_response :success
    assert_select ".guide .page-title", "Getting started"
    assert_select ".guide__section--first-steps .guide__step", 5
    assert_select ".guide__section--places", /Settings/
    assert_select ".guide__join a[href=?]", new_registration_path
  end

  test "the old How it works address leads to Getting started" do
    get "/how-it-works"
    assert_redirected_to "/getting-started"
  end

  test "players find it in the Menu" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".menu__items a.menu__guide[href=?]", getting_started_path
    get getting_started_path
    assert_response :success
    assert_select ".guide__join", 0
  end

  test "any staff member can read the staff guide from the admin menu" do
    sign_in_as(accounts(:builder))
    get admin_getting_started_path
    assert_response :success
    assert_select ".guide--admin .page-title", "Getting started for staff"
    assert_select ".admin-menu__link--guide[aria-current=page]"
  end

  test "players are turned away from the staff guide" do
    sign_in_as(accounts(:alice))
    get admin_getting_started_path
    assert_redirected_to root_path
  end
end
