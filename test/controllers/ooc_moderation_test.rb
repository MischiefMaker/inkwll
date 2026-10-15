require "test_helper"

class OocModerationTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "players edit their own messages, which then say (edited)" do
    sign_in_as(accounts(:bob))
    message = ooc_messages(:hello)
    get edit_ooc_message_path(message)
    assert_response :success

    patch ooc_message_path(message), params: { ooc_message: { body: "Hello, all!" } }
    assert_equal "Hello, all!", message.reload.body
    assert message.edited_at
    assert_not message.edited_by_staff?

    get ooc_messages_path
    assert_select "#ooc_message_#{message.id} .ooc-message__edited", "(edited)"
  end

  test "players delete their own messages, which stay as Deleted" do
    sign_in_as(accounts(:bob))
    message = ooc_messages(:hello)
    assert_no_difference("OocMessage.count") { delete ooc_message_path(message) }
    assert message.reload.deleted?

    get ooc_messages_path
    assert_select "#ooc_message_#{message.id} .ooc-message__body--deleted", "Deleted"
    assert_select "#ooc_message_#{message.id}", text: /Hello, everyone/, count: 0
  end

  test "players can't change someone else's message" do
    sign_in_as(accounts(:alice))
    message = ooc_messages(:hello)
    patch ooc_message_path(message), params: { ooc_message: { body: "Hacked" } }
    delete ooc_message_path(message)
    assert_equal "Hello, everyone!", message.reload.body
    assert_not message.deleted?
  end

  test "guests can't change messages" do
    message = ooc_messages(:hello)
    delete ooc_message_path(message)
    assert_redirected_to new_session_path
    assert_not message.reload.deleted?
  end

  test "staff edit and remove anyone's message, and it says so" do
    sign_in_as(accounts(:scribe))
    message = ooc_messages(:hello)
    patch ooc_message_path(message), params: { ooc_message: { body: "Hello!" } }
    assert message.reload.edited_by_staff?

    delete ooc_message_path(message)
    assert message.reload.removed_by_staff?
    get ooc_messages_path
    assert_select "#ooc_message_#{message.id} .ooc-message__body--deleted", "Removed by staff"
  end

  test "a player sees the controls only on their own messages" do
    sign_in_as(accounts(:bob))
    get ooc_messages_path
    assert_select "style", text: /data-author="#{accounts(:bob).id}"/
    assert_select "body.is-staff", count: 0
  end

  test "Block on a message fills in a chat-only ban for its author" do
    sign_in_as(accounts(:scribe))
    get new_admin_ban_path(ooc_message_id: ooc_messages(:hello).id)
    assert_select "input[name='ban[player_name]'][value=Bob]"
    assert_select "input[type=checkbox][name='ban[chat_only]'][checked]"
  end

  test "a chat-only ban stops posting in the chat but not playing" do
    bob = accounts(:bob)
    Ban.create!(account: bob, banned_by: accounts(:scribe), reason: "Spamming", chat_only: true, expires_at: 1.day.from_now)
    sign_in_as(bob)

    get root_path
    assert_response :success
    assert_no_difference("OocMessage.count") do
      post ooc_messages_path, params: { ooc_message: { body: "Hi" } }, as: :turbo_stream
    end
    assert_match "post in the OOC Chat until", response.body

    travel 2.days
    assert_difference("OocMessage.count") do
      post ooc_messages_path, params: { ooc_message: { body: "Hi again" } }, as: :turbo_stream
    end
  end

  test "creating a chat-only ban keeps the player logged in" do
    sign_in_as(accounts(:scribe))
    assert_no_difference("accounts(:bob).sessions.count") do
      post admin_bans_path, params: { ban: { player_name: "Bob", reason: "Rude", chat_only: "1" } }
    end
    assert Ban.last.chat_only?
  end

  test "guests can be blocked from the chat by address" do
    get ooc_messages_path
    travel 5.seconds
    Ban.create!(ip_range: "127.0.0.1", banned_by: accounts(:scribe), reason: "Spam", chat_only: true)
    assert_no_difference("OocMessage.count") do
      post ooc_messages_path, params: { guest_name: "Spammer", ooc_message: { body: "Buy stuff" } }
    end
  end
end
