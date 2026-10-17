require "test_helper"

class NewPlayerBadgeTest < ActionDispatch::IntegrationTest
  setup do
    accounts(:bob).update_columns(created_at: 3.days.ago)
    accounts(:alice).update_columns(created_at: 3.months.ago)
  end

  test "a player's first two weeks show a New mark in Here and the directory" do
    get room_path(rooms(:commons))
    assert_select ".room-here li", text: /Sable/ do
      assert_select ".new-player"
    end
    assert_select ".room-here li", text: /Wren/ do
      assert_select ".new-player", count: 0
    end

    get directory_path
    assert_select ".directory__item", text: /Sable/ do
      assert_select ".new-player"
    end
  end

  test "the New mark shows beside OOC Chat messages" do
    sign_in_as(accounts(:bob))
    post ooc_messages_path, params: { ooc_message: { body: "Hello, I'm new!" } }
    get ooc_messages_path
    assert_select ".ooc-message", text: /I'm new/ do
      assert_select ".new-player"
    end
  end

  test "the mark goes after two weeks" do
    accounts(:bob).update_columns(created_at: 15.days.ago)
    assert_not accounts(:bob).new_player?
  end
end
