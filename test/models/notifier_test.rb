require "test_helper"

class NotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @scene = scenes(:duel)
    @bob = accounts(:bob)
  end

  test "players who chose no emails get none" do
    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges.") }
    assert_no_emails
  end

  test "every time: one email with the missed Passages, then none until it's read" do
    @bob.update!(email_notifications: "every_time")

    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges.") }
    assert_emails 1
    email = ActionMailer::Base.deliveries.last
    assert_equal [ "bob@example.com" ], email.to
    assert_includes email.subject, "Duel at Dawn"
    assert_includes email.text_part.body.to_s, "Wren lunges."
    assert email.header["List-Unsubscribe"]

    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges again.") }
    assert_emails 1

    scene_participants(:duel_sable).reload.mark_read!
    perform_enqueued_jobs { @scene.post!(characters(:wren), "And again.") }
    assert_emails 2
  end

  test "the poster isn't emailed about their own Passage" do
    accounts(:alice).update!(email_notifications: "every_time")
    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges.") }
    assert_no_emails
  end

  test "when away: no email if they came back to the site in the meantime" do
    @bob.update!(email_notifications: "when_away", last_seen_at: Time.current)
    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges.") }
    assert_no_emails

    @bob.update!(last_seen_at: 1.hour.ago)
    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges again.") }
    assert_emails 1
  end

  test "only my turn: in a Chapter of three or more, email only when the turn comes up" do
    scene = Scene.start!(character: characters(:wren), title: "Crowd")
    scene.join!(characters(:sable))
    scene.join!(characters(:finch))
    @bob.update!(email_notifications: "every_time", email_only_my_turn: true)

    # Finch opens, so it's Wren's turn next, then Sable's.
    perform_enqueued_jobs { scene.post!(characters(:finch), "Finch opens.") }
    assert_no_emails

    perform_enqueued_jobs { scene.post!(characters(:wren), "Wren answers.") }
    assert_emails 1
    assert_includes ActionMailer::Base.deliveries.last.subject, "Your turn"
  end

  test "@mentions email even outside the Chapter's usual emails" do
    @bob.update!(email_notifications: "after_days")
    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren looks at @Sable.") }
    assert_emails 1
    assert_includes ActionMailer::Base.deliveries.last.subject, "mentioned you"
  end

  test "@mentions only count when the whole name matches" do
    Character.create!(account: accounts(:alice), name: "Sab", room: rooms(:commons))
    assert_equal [ "Sable" ], Notifier.mentioned_characters(Pose.new(body: "Hi @sable, hi @Sablecloak.")).map(&:name)
    assert_equal [ "Sab", "Sable" ], Notifier.mentioned_characters(Pose.new(body: "@Sab's eyes meet @Sable.")).map(&:name).sort
  end

  test "archived players get no emails" do
    @bob.update!(email_notifications: "every_time")
    @bob.update_column(:archived_at, Time.current)
    perform_enqueued_jobs { @scene.post!(characters(:wren), "Wren lunges at @Sable.") }
    assert_no_emails

    @bob.update!(email_notifications: "after_days", email_after_days: 3, last_seen_at: 4.days.ago)
    perform_enqueued_jobs { DigestJob.perform_now }
    assert_no_emails
  end

  test "the digest covers what an away player missed, once" do
    @bob.update!(email_notifications: "after_days", email_after_days: 3, last_seen_at: 4.days.ago)
    @scene.post!(characters(:wren), "Wren lunges.")

    perform_enqueued_jobs { DigestJob.perform_now }
    assert_emails 1
    assert_includes ActionMailer::Base.deliveries.last.text_part.body.to_s, "Wren lunges."

    perform_enqueued_jobs { DigestJob.perform_now }
    assert_emails 1
  end

  test "no digest for a player seen recently" do
    @bob.update!(email_notifications: "after_days", email_after_days: 3, last_seen_at: 1.day.ago)
    @scene.post!(characters(:wren), "Wren lunges.")
    perform_enqueued_jobs { DigestJob.perform_now }
    assert_no_emails
  end

  test "long gaps show the latest 20 Passages and how many more" do
    @bob.update!(email_notifications: "every_time")
    scene_participants(:duel_sable).update!(notified_up_to: 99)
    25.times { |i| @scene.post!(characters(:wren), "Line #{i}") }
    scene_participants(:duel_sable).update!(notified_up_to: 0)

    perform_enqueued_jobs { Notifier.email_chapter(scene_participants(:duel_sable).reload) }
    body = ActionMailer::Base.deliveries.last.text_part.body.to_s
    assert_includes body, "and 5 earlier"
    assert_includes body, "Line 24"
    assert_not_includes body, "Line 4\n"
  end
end
