require "test_helper"

class MessagesTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "messaging a player by name, and replying" do
    sign_in_as(accounts(:alice))
    post conversations_path, params: { to: "Bob", subject: "Scene tonight?", body: "Want to play?" }
    conversation = Conversation.last
    assert_redirected_to conversation_path(conversation)

    sign_in_as(accounts(:bob))
    get root_path
    assert_select ".message-count__number", text: "1"
    get conversation_path(conversation)
    assert_select ".conversation-message__sender", text: "Alice"
    post conversation_messages_path(conversation), params: { message: { body: "Sure!" } }
    assert_equal 2, conversation.messages.count

    get root_path
    assert_select ".message-count__number", count: 0
  end

  test "messaging the player of a character keeps them anonymous" do
    sign_in_as(accounts(:alice))
    post conversations_path, params: { to: "Sable", subject: "Hi", body: "Who are you?" }
    conversation = Conversation.last
    assert_equal accounts(:bob), conversation.members.last.account

    get conversation_path(conversation)
    assert_select ".conversation__members", text: /The player of Sable/
    assert_select "body", text: /Bob/, count: 0

    sign_in_as(accounts(:bob))
    post conversation_messages_path(conversation), params: { message: { body: "Hello!" } }
    sign_in_as(accounts(:alice))
    get conversation_path(conversation)
    assert_select ".conversation-message__sender", text: "The player of Sable"
  end

  test "when the game shows players, messaging a character goes to the player by name" do
    GameSetting.current.update!(players_public: true)
    sign_in_as(accounts(:alice))
    post conversations_path, params: { to: "Sable", subject: "Hi", body: "Hello" }
    assert_nil Conversation.last.members.last.via_character
  end

  test "only people in a conversation can read it" do
    sign_in_as(accounts(:alice))
    post conversations_path, params: { to: "Bob", subject: "Private", body: "Secret" }
    sign_in_as(accounts(:scribe))
    get conversation_path(Conversation.last)
    assert_response :not_found
  end

  test "unknown names are refused" do
    sign_in_as(accounts(:alice))
    assert_no_difference "Conversation.count" do
      post conversations_path, params: { to: "Nobody Here", subject: "Hi", body: "Hello" }
    end
    assert_response :unprocessable_entity
  end

  test "new messages are emailed to players who asked for activity emails" do
    accounts(:bob).update!(email_notifications: "every_time")
    sign_in_as(accounts(:alice))
    assert_enqueued_jobs 1, only: MessageEmailJob do
      post conversations_path, params: { to: "Bob", subject: "Hi", body: "Hello" }
    end
  end

  test "leaving a conversation" do
    sign_in_as(accounts(:alice))
    post conversations_path, params: { to: "Bob", subject: "Hi", body: "Hello" }
    sign_in_as(accounts(:bob))
    delete conversation_membership_path(Conversation.last)
    assert_not Conversation.last.member_for(accounts(:bob)).active?
  end
end
