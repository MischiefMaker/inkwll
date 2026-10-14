require "test_helper"

# Checks for the fixes from the security review (docs in /mnt/project-files/security/review.md).
class SecurityTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "direct uploads to storage are switched off" do
    post "/rails/active_storage/direct_uploads", params: { blob: { filename: "x.bin", byte_size: 500_000_000, checksum: "x", content_type: "application/octet-stream" } }
    assert_response :not_found
  end

  test "changing your email needs your current password and tells the old address" do
    sign_in_as(accounts(:bob))
    patch notification_settings_path, params: { account: { email: "thief@example.com" } }
    assert_response :unprocessable_entity
    assert_equal "bob@example.com", accounts(:bob).reload.email

    assert_enqueued_emails 1 do
      patch notification_settings_path, params: { current_password: "password", account: { email: "new@example.com" } }
    end
    assert_equal "new@example.com", accounts(:bob).reload.email
  end

  test "one player can't switch a hidden Chapter to Open" do
    sign_in_as(accounts(:bob))
    patch scene_path(scenes(:secret)), params: { scene: { visibility: "joinable" } }
    assert scenes(:secret).reload.visibility_hidden?
  end

  test "a hidden Chapter opens up once every player agrees" do
    sign_in_as(accounts(:bob))
    post scene_public_consent_path(scenes(:secret))
    assert scenes(:secret).reload.made_public_at
  end

  test "finished Chapters' settings can't be changed" do
    sign_in_as(accounts(:alice))
    scenes(:duel).finish!(by: characters(:wren))
    patch scene_path(scenes(:duel)), params: { scene: { title: "Changed" } }
    assert_equal "Duel at Dawn", scenes(:duel).reload.title
  end

  test "Passages can't be edited or removed once staff lock the Chapter" do
    sign_in_as(accounts(:alice))
    scenes(:duel).update!(locked_at: Time.current)
    patch scene_pose_path(scenes(:duel), poses(:duel_one)), params: { pose: { body: "Changed" } }
    delete scene_pose_path(scenes(:duel), poses(:duel_one))
    assert_equal "Wren draws her blade.", poses(:duel_one).reload.body
    assert_not poses(:duel_one).removed?
  end

  test "IP bans can't be too wide, and never stop the Founder or staff at the banner's level" do
    ban = Ban.new(ip_range: "0.0.0.0/0", reason: "Oops", banned_by: accounts(:scribe))
    assert_not ban.valid?

    Ban.create!(ip_range: "127.0.0.0/16", reason: "Brigade", banned_by: accounts(:scribe))
    assert Ban.for(account: accounts(:bob), ip: "127.0.0.1")
    assert_nil Ban.for(account: accounts(:scribe), ip: "127.0.0.1")
    assert_nil Ban.for(account: accounts(:wellkeeper), ip: "127.0.0.1")
    assert_nil Ban.for(account: accounts(:founder), ip: "127.0.0.1")
  end

  test "a Scribe can't lift a Wellkeeper's ban" do
    ban = Ban.create!(account: accounts(:bob), reason: "Spam", banned_by: accounts(:wellkeeper))
    sign_in_as(accounts(:scribe))
    patch admin_ban_path(ban)
    assert ban.reload.in_force?
  end

  test "passwords need at least 8 characters" do
    account = Account.new(display_name: "Shorty", email: "s@example.com", password: "abc", password_confirmation: "abc")
    assert_not account.valid?
    assert account.errors[:password].any?
  end
end
