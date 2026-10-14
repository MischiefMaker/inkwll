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

  test "passwords need 10 characters, a number, a capital and a lower-case letter" do
    { "Abc1" => /too short/, "abcdefghij1" => /capital/, "ABCDEFGHIJ1" => /lower-case/, "Abcdefghijk" => /number/ }.each do |password, problem|
      account = Account.new(display_name: "Shorty", email: "s@example.com", password: password, password_confirmation: password)
      assert_not account.valid?, password
      assert_match problem, account.errors[:password].to_sentence
    end
    assert Account.new(display_name: "Strong", email: "st@example.com", password: "Lanterns2026").valid?
  end

  test "someone muted for posting too fast can't post until it ends or staff lift it" do
    accounts(:alice).update_column(:muted_until, 5.minutes.from_now)
    sign_in_as(accounts(:alice))
    assert_no_difference -> { OocMessage.count } do
      post ooc_messages_path, params: { ooc_message: { body: "hello" } }
    end
    assert_match(/muted/, flash[:alert])

    sign_in_as(accounts(:bob))
    post unmute_admin_account_path(accounts(:alice))
    assert accounts(:alice).reload.muted_until.present?, "players can't lift mutes"

    sign_in_as(accounts(:scribe))
    post unmute_admin_account_path(accounts(:alice))
    assert_nil accounts(:alice).reload.muted_until
  end

  test "one player's characters share a limit on gallery pictures" do
    stub_const = GalleryImage::MAX_PER_PLAYER
    GalleryImage.send(:remove_const, :MAX_PER_PLAYER)
    GalleryImage.const_set(:MAX_PER_PLAYER, 1)
    picture = -> { { io: file_fixture("pixel.png").open, filename: "pixel.png", content_type: "image/png" } }
    characters(:wren).gallery_images.create!(image: picture.call)
    extra = accounts(:alice).characters.create!(name: "Second").gallery_images.new(image: picture.call)
    assert_not extra.valid?
    assert_match(/between them/, extra.errors.full_messages.to_sentence)
  ensure
    GalleryImage.send(:remove_const, :MAX_PER_PLAYER)
    GalleryImage.const_set(:MAX_PER_PLAYER, stub_const)
  end
end
