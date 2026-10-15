require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper sees every quick action and what is waiting" do
    characters(:wren).update!(status: "submitted", submitted_at: Time.current)
    sign_in_as(accounts(:wellkeeper))
    get admin_root_path
    assert_response :success
    %w[ character place area players characters applications reports bans settings ].each do |kind|
      assert_select ".admin-quick__button--#{kind}"
    end
    assert_select ".admin-attention__item--applications .admin-attention__count", text: "1"
  end

  test "a Build Page only sees the quick actions and waiting work their job allows" do
    characters(:wren).update!(status: "submitted", submitted_at: Time.current)
    sign_in_as(accounts(:builder))
    get admin_root_path
    assert_response :success
    assert_select ".admin-quick__button--place"
    %w[ players characters applications reports bans settings ].each do |kind|
      assert_select ".admin-quick__button--#{kind}", count: 0
    end
    assert_select ".admin-attention__item", count: 0
    assert_select ".admin-attention__empty"
  end

  test "a player is turned away from the admin front page" do
    sign_in_as(accounts(:alice))
    get admin_root_path
    assert_redirected_to root_path
  end
end
