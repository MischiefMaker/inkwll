require "test_helper"

class PrivateChatsTest < ActionDispatch::IntegrationTest
  test "paging a player opens a live chat tab for both, kept in Messages" do
    sign_in_as(accounts(:alice))
    post pages_path, params: { to: accounts(:bob).display_name, body: "Fancy a scene?" }, as: :turbo_stream
    assert_response :success
    conversation = Conversation.find_by(subject: Conversation::PAGE_SUBJECT)
    assert_equal "Fancy a scene?", conversation.messages.last.body
    assert conversation.members.all?(&:live_open?)
    assert_select ".chat-tabs__tab--private"

    get root_path
    assert_select ".chat-pane--private .private-chat-message__body", text: "Fancy a scene?"

    # A second page goes to the same conversation.
    sign_in_as(accounts(:bob))
    post pages_path, params: { to: accounts(:alice).display_name, body: "Sure!" }, as: :turbo_stream
    assert_equal 1, Conversation.where(subject: Conversation::PAGE_SUBJECT).count
    assert_equal 2, conversation.messages.count
  end

  test "sending from a tab, closing it, and opening a conversation from Messages" do
    conversation = Conversation.page!(from: accounts(:alice), to: [ accounts(:bob), nil ], body: "Hi")
    sign_in_as(accounts(:bob))
    post conversation_live_messages_path(conversation), params: { message: { body: "Hello back" } }
    assert_response :no_content
    assert_equal "Hello back", conversation.messages.last.body

    delete conversation_live_tab_path(conversation), as: :turbo_stream
    assert_not conversation.member_for(accounts(:bob)).reload.live_open?
    post conversation_live_tab_path(conversation)
    assert conversation.member_for(accounts(:bob)).reload.live_open?

    patch conversation_reading_path(conversation)
    assert_not conversation.member_for(accounts(:bob)).reload.unread?
  end

  test "people outside the conversation can't post, open or read it" do
    conversation = Conversation.page!(from: accounts(:alice), to: [ accounts(:bob), nil ], body: "Hi")
    sign_in_as(accounts(:builder))
    post conversation_live_messages_path(conversation), params: { message: { body: "Me too" } }
    assert_response :not_found
    post conversation_live_tab_path(conversation)
    assert_response :not_found
    patch conversation_reading_path(conversation)
    assert_response :not_found
    assert_equal 1, conversation.messages.count
  end

  test "an unknown name says so" do
    sign_in_as(accounts(:alice))
    post pages_path, params: { to: "Nobody At All", body: "Hello?" }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_select ".private-chat__problem", text: /no player or character called/
  end
end
