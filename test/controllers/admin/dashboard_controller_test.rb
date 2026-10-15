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

  test "the old link list is gone, and what it linked to is still in the side menu" do
    sign_in_as(accounts(:wellkeeper))
    get admin_root_path
    assert_select ".admin-sections", count: 0
    [ admin_areas_path, admin_accounts_path, admin_reports_path, admin_bans_path, admin_characters_path,
      edit_admin_features_path, edit_admin_skin_path, edit_admin_game_settings_path ].each do |path|
      assert_select ".admin-menu a[href='#{path}']"
    end
  end
end
