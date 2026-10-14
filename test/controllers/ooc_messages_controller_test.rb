require "test_helper"

class OocMessagesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "shows recent messages under player names" do
    get ooc_messages_path

    assert_response :success
    assert_select ".ooc-message__author", "Bob"
  end

  test "posting a message saves it and broadcasts it to everyone" do
    assert_difference "OocMessage.count" do
      assert_turbo_stream_broadcasts :ooc_chat do
        post ooc_messages_path, params: { ooc_message: { body: "Hi!" } }, as: :turbo_stream
      end
    end
    assert_equal accounts(:alice), OocMessage.last.account
  end
end
