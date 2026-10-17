require "test_helper"

class IcBoardsTest < ActionDispatch::IntegrationTest
  setup do
    @board = ForumBoard.create!(name: "Town Square Notices", in_character: true)
  end

  test "on an in-character board people post as one of their characters" do
    sign_in_as(accounts(:alice))
    post forum_board_forum_topics_path(@board), params: { forum_topic: { title: "Lost cat", body: "Grey, answers to Moth.", character_id: characters(:wren).id } }
    topic = @board.topics.last
    assert_equal characters(:wren), topic.character
    assert_equal characters(:wren), topic.posts.first.character

    post forum_topic_forum_posts_path(topic), params: { forum_post: { body: "Found it!", character_id: characters(:moth).id } }
    assert_equal characters(:moth), topic.posts.last.character

    sign_out
    get forum_topic_path(topic)
    assert_select ".forum-author--character", text: "Wren"
    assert_select ".forum-author--character", text: "Moth"
    assert_no_match accounts(:alice).display_name, css_select(".forum-posts").text
  end

  test "you can't post as someone else's character, or without one" do
    sign_in_as(accounts(:alice))
    post forum_board_forum_topics_path(@board), params: { forum_topic: { title: "Hi", body: "Hello", character_id: characters(:sable).id } }
    assert_equal 0, @board.topics.count
    post forum_board_forum_topics_path(@board), params: { forum_topic: { title: "Hi", body: "Hello" } }
    assert_equal 0, @board.topics.count
  end

  test "OOC boards stay under the player's name, and staff set the kind" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_forum_board_path(@board), params: { forum_board: { in_character: "0" } }
    assert_not @board.reload.in_character?
  end
end
