require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "the player list is split into pages, and a page number out of range still works" do
    sign_in_as(accounts(:scribe))

    get admin_accounts_path(page: 999)
    assert_response :success
    get admin_accounts_path(page: -3)
    assert_response :success
  end

  test "a Scribe can make a player a Page with jobs, and a Storyteller" do
    sign_in_as(accounts(:scribe))

    patch admin_account_path(accounts(:alice)), params: { account: { staff_level: "page", job_flags: [ "", "app" ], storyteller: "1" } }

    alice = accounts(:alice).reload
    assert alice.page?
    assert_equal [ "app" ], alice.job_flags
    assert alice.storyteller?
  end

  test "a Scribe can't make someone a Scribe or edit a Wellkeeper" do
    sign_in_as(accounts(:scribe))

    patch admin_account_path(accounts(:alice)), params: { account: { staff_level: "scribe" } }
    assert accounts(:alice).reload.player?

    get edit_admin_account_path(accounts(:wellkeeper))
    assert_redirected_to root_path
  end

  test "only a Founder can make a Wellkeeper" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_account_path(accounts(:scribe)), params: { account: { staff_level: "wellkeeper" } }
    assert accounts(:scribe).reload.scribe?

    sign_in_as(accounts(:founder))
    patch admin_account_path(accounts(:scribe)), params: { account: { staff_level: "wellkeeper" } }
    assert accounts(:scribe).reload.wellkeeper?
  end

  test "Pages can't manage staff" do
    sign_in_as(accounts(:builder))
    get admin_accounts_path
    assert_redirected_to root_path
  end

  test "staff can make a password reset link that lets the player pick a new password" do
    sign_in_as(accounts(:scribe))
    post reset_link_admin_account_path(accounts(:alice))
    assert_response :success
    link = css_select(".account-password__link-field").first["value"]
    token = link.split("/passwords/").last.split("/").first

    sign_out
    get edit_password_path(token)
    assert_response :success
    put password_path(token), params: { password: "Brandnew12345", password_confirmation: "Brandnew12345" }
    assert Account.log_in("alice", "Brandnew12345")

    get edit_password_path(token)
    assert_redirected_to new_password_path
  end

  test "Pages and players can't make reset links, and Scribes can't for a Wellkeeper" do
    sign_in_as(accounts(:builder))
    post reset_link_admin_account_path(accounts(:alice))
    assert_redirected_to root_path

    sign_in_as(accounts(:scribe))
    post reset_link_admin_account_path(accounts(:wellkeeper))
    assert_redirected_to root_path
  end
end
