require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
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
end
