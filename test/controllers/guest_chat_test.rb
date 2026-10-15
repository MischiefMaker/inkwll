require "test_helper"

class GuestChatTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "a guest picks a name and chats" do
    get ooc_messages_path
    assert_response :success
    travel 5.seconds

    post ooc_messages_path, params: { guest_name: "Curious Cat", ooc_message: { body: "How do I apply?" } }
    message = OocMessage.last
    assert_equal "Curious Cat (guest)", message.author_name
    assert message.ip_address

    # The name is remembered for the rest of the visit.
    post ooc_messages_path, params: { ooc_message: { body: "Thanks!" } }
    assert_equal "Curious Cat", OocMessage.last.guest_name
  end

  test "posting straight away, or filling in the hidden box, is treated as a bot" do
    get ooc_messages_path
    assert_no_difference("OocMessage.count") do
      post ooc_messages_path, params: { guest_name: "Speedy", ooc_message: { body: "Hi" } }
    end

    travel 5.seconds
    assert_no_difference("OocMessage.count") do
      post ooc_messages_path, params: { guest_name: "Bot", website: "spam.example", ooc_message: { body: "Hi" } }
    end
  end

  test "guests can't post links or use a player's name" do
    get ooc_messages_path
    travel 5.seconds
    assert_no_difference("OocMessage.count") do
      post ooc_messages_path, params: { guest_name: "Alice", ooc_message: { body: "Hi" } }
      post ooc_messages_path, params: { guest_name: "Visitor", ooc_message: { body: "Cheap pills at http://spam.example" } }
    end
  end

  test "guests without a chat page visit can't post" do
    assert_no_difference("OocMessage.count") do
      post ooc_messages_path, params: { guest_name: "Drive By", ooc_message: { body: "Hi" } }
    end
  end

  test "the game can turn guest chat off" do
    GameSetting.current.update!(guest_chat: false)
    get ooc_messages_path
    assert_redirected_to new_session_path
  end

  test "a banned address can't chat as a guest" do
    Ban.create!(ip_range: "127.0.0.1", reason: "Spam", banned_by: accounts(:wellkeeper))
    get ooc_messages_path
    assert_redirected_to new_session_path
  end

  test "staff can remove a guest's messages" do
    OocMessage.create!(guest_name: "Spammer", body: "buy now", ip_address: "203.0.113.9")
    sign_in_as(accounts(:wellkeeper))
    get admin_bans_path
    assert_select "td", text: "Spammer"
    assert_difference("OocMessage.count", -1) do
      delete admin_guest_messages_path(ip: "203.0.113.9")
    end
  end

  test "the log in and chat pages keep the guest top bar, and log in has the OOC Chat beside it" do
    get new_session_path
    assert_select ".site-header--guest a[href=?]", root_path
    assert_select ".site-header__preview", count: 0
    assert_select ".ooc-sidebar"
    assert_select ".guest-chat-hello", text: /say hello in the OOC Chat/

    get new_registration_path
    assert_select ".ooc-sidebar"
    assert_select ".guest-chat-hello"

    # Guests previewing the game see it too: it's how the game welcomes them.
    get root_path
    assert_select ".site-header--guest"
    assert_select ".ooc-sidebar"

    # The chat page shows the chat itself, so no second one beside it.
    get ooc_messages_path
    assert_select ".site-header--guest"
    assert_select ".ooc-sidebar", count: 0
  end

  test "with guest chat off, guests see no OOC Chat beside the page" do
    GameSetting.current.update!(guest_chat: false)
    get new_session_path
    assert_select ".site-header--guest"
    assert_select ".ooc-sidebar", count: 0
    assert_select ".guest-chat-hello", count: 0
  end
end
