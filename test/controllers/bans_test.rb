require "test_helper"

class BansTest < ActionDispatch::IntegrationTest
  test "a banned player is logged out and can't log back in" do
    sign_in_as(accounts(:bob))
    Ban.create!(account: accounts(:bob), reason: "Harassment", banned_by: accounts(:scribe))

    get root_path
    assert_redirected_to new_session_path
    assert_match "banned", flash[:alert]

    post session_path, params: { username: "bob", password: "password" }
    assert_redirected_to new_session_path
    assert_match "Harassment", flash[:alert]
  end

  test "an IP ban stops sign-ups from that address" do
    Ban.create!(ip_range: "127.0.0.0/16", reason: "Brigade", banned_by: accounts(:scribe))
    assert_no_difference "Account.count" do
      post registration_path, params: { account: { display_name: "Troll", email: "t@example.com", password: "Secret12345", password_confirmation: "Secret12345" } }
    end
  end

  test "bans can end on a date, and be lifted" do
    ban = Ban.create!(account: accounts(:bob), reason: "Cool off", banned_by: accounts(:scribe), expires_at: 2.days.from_now)
    assert_equal ban, Ban.for(account: accounts(:bob))
    travel 3.days do
      assert_nil Ban.for(account: accounts(:bob))
    end
    ban.lift!
    assert_nil Ban.for(account: accounts(:bob))
  end

  test "the VPN block uses the downloaded list" do
    VpnRange.replace_with!("127.0.0.0/8\n# comment\n10.0.0.0/8\n")
    assert VpnRange.covers?("127.0.0.1")
    GameSetting.current.update!(block_vpns: true)

    assert_no_difference "Account.count" do
      post registration_path, params: { account: { display_name: "Vpn", email: "v@example.com", password: "Secret12345", password_confirmation: "Secret12345" } }
    end
    assert_match "VPN", flash[:alert]
  end

  test "Scribes ban from the admin panel, but not staff above them" do
    sign_in_as(accounts(:scribe))
    post admin_bans_path, params: { ban: { player_name: "bob", reason: "Spam" } }
    assert Ban.for(account: accounts(:bob))

    post admin_bans_path, params: { ban: { player_name: "wellkeeper", reason: "No" } }
    assert_nil Ban.for(account: accounts(:wellkeeper))
  end

  test "a ban with a date that doesn't exist is turned back, not saved" do
    sign_in_as(accounts(:scribe))
    assert_no_difference "Ban.count" do
      post admin_bans_path, params: { ban: { player_name: "bob", reason: "Spam", expires_on: "2027-02-31" } }
    end
    assert_response :unprocessable_entity
  end
end
