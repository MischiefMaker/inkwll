require "test_helper"

# Leftover Probe players from the old live-game browser check (see
# lib/inkwll/probes.rb).
class ProbesTest < ActiveSupport::TestCase
  setup do
    @probe = Account.create!(display_name: "Probe1760000000000", email: "probe1760000000000@example.com",
      password: "Testing123A", password_confirmation: "Testing123A", email_notifications: "off")
    @character = @probe.characters.create!(name: "Tester 0000")
    @board = ForumBoard.create!(name: "Advertising", who_can_start: "everyone", who_can_reply: "everyone")
    @topic = ForumTopic.start!(board: @board, account: @probe, title: "Probe thread", body: "Testing.")
    @reply = ForumTopic.start!(board: @board, account: accounts(:alice), title: "Real thread", body: "Hello")
      .posts.create!(account: @probe, body: "A probe reply.")
    @probe.ooc_messages.create!(body: "Probe says hi")
  end

  test "only Probe-named players with an example.com email are matched" do
    lookalike = Account.create!(display_name: "Probe1760000000001", email: "someone@realmail.test",
      password: "Testing123A", password_confirmation: "Testing123A", email_notifications: "off")
    assert_equal [ @probe ], Inkwll::Probes.accounts.to_a
    assert_not_includes Inkwll::Probes.accounts, lookalike
  end

  test "cleaning up archives Probe players, replaces the shared password and removes what they posted" do
    Inkwll::Probes.clean_up(StringIO.new)

    assert @probe.reload.archived?
    assert_nil Account.log_in(@probe.display_name, "Testing123A")
    assert_not @probe.authenticate("Testing123A")
    assert @character.reload.retired_at.present?
    assert_not ForumTopic.exists?(@topic.id)
    assert_not ForumPost.exists?(@reply.id)
    assert_equal 0, @probe.ooc_messages.count
    assert ForumTopic.exists?(title: "Real thread"), "other players' threads stay"
  end

  test "the list changes nothing" do
    output = StringIO.new
    Inkwll::Probes.report(output)
    assert_match "1 Probe player found", output.string
    assert_not @probe.reload.archived?
  end
end
