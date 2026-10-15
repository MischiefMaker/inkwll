require "test_helper"

class ForumBoardsTest < ActionDispatch::IntegrationTest
  setup do
    @ads = ForumBoard.create!(name: "Advertising", who_can_start: "everyone", who_can_reply: "everyone")
    @news = ForumBoard.create!(name: "News", who_can_start: "staff", who_can_reply: "nobody")
  end

  test "the front page lists the boards after the Areas" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".forum-section .forum-board", 2
    assert_select ".forum-board__title", "Advertising"
  end

  test "guests can read a board but not start threads" do
    get forum_board_path(@ads)
    assert_response :success
    post forum_board_forum_topics_path(@ads), params: { forum_topic: { title: "Spam", body: "Spam" } }
    assert_redirected_to new_session_path
  end

  test "a player can start a thread and reply" do
    sign_in_as(accounts(:alice))
    assert_difference -> { ForumTopic.count } => 1, -> { ForumPost.count } => 1 do
      post forum_board_forum_topics_path(@ads), params: { forum_topic: { title: "Seeking a rival", body: "**Anyone?**" } }
    end
    topic = ForumTopic.last
    assert_redirected_to forum_topic_path(topic)

    post forum_topic_forum_posts_path(topic), params: { forum_post: { body: "Me!" } }
    assert_equal 2, topic.reload.posts_count

    get forum_topic_path(topic)
    assert_select ".forum-post", 2
    assert_select ".forum-post__body strong", "Anyone?"
  end

  test "a thread needs a title and a message" do
    sign_in_as(accounts(:alice))
    assert_no_difference -> { ForumTopic.count } do
      post forum_board_forum_topics_path(@ads), params: { forum_topic: { title: "", body: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "a player can't start a thread on a staff-only board" do
    sign_in_as(accounts(:alice))
    assert_no_difference -> { ForumTopic.count } do
      post forum_board_forum_topics_path(@news), params: { forum_topic: { title: "Hi", body: "Hello" } }
    end
    assert_redirected_to forum_board_path(@news)
  end

  test "nobody can reply on a board with replies switched off" do
    topic = ForumTopic.start!(board: @news, account: accounts(:wellkeeper), title: "Launch", body: "We're open.")
    sign_in_as(accounts(:alice))
    assert_no_difference -> { ForumPost.count } do
      post forum_topic_forum_posts_path(topic), params: { forum_post: { body: "Yay" } }
    end
    get forum_topic_path(topic)
    assert_select ".forum-reply-form", 0
  end

  test "a locked thread takes no replies from players, but does from moderators" do
    topic = ForumTopic.start!(board: @ads, account: accounts(:bob), title: "Old ad", body: "Closed now.")
    topic.update!(locked_at: Time.current)

    sign_in_as(accounts(:alice))
    assert_no_difference -> { ForumPost.count } do
      post forum_topic_forum_posts_path(topic), params: { forum_post: { body: "Too late?" } }
    end

    sign_in_as(accounts(:scribe))
    assert_difference -> { ForumPost.count } do
      post forum_topic_forum_posts_path(topic), params: { forum_post: { body: "Closing this." } }
    end
  end

  test "players edit only their own posts" do
    topic = ForumTopic.start!(board: @ads, account: accounts(:bob), title: "Bob's ad", body: "Original")
    post_record = topic.posts.first

    sign_in_as(accounts(:alice))
    patch forum_topic_forum_post_path(topic, post_record), params: { forum_post: { body: "Hacked" } }
    assert_equal "Original", post_record.reload.body

    sign_in_as(accounts(:bob))
    patch forum_topic_forum_post_path(topic, post_record), params: { forum_post: { body: "Updated" } }
    assert_equal "Updated", post_record.reload.body
    assert post_record.edited_at
  end

  test "only moderators pin, lock and delete" do
    topic = ForumTopic.start!(board: @ads, account: accounts(:alice), title: "My ad", body: "Hi")

    sign_in_as(accounts(:alice))
    patch forum_topic_path(topic), params: { forum_topic: { title: "My better ad", pinned: "1", locked: "1" } }
    topic.reload
    assert_equal "My better ad", topic.title
    assert_not topic.pinned?
    assert_not topic.locked?
    assert_no_difference -> { ForumTopic.count } do
      delete forum_topic_path(topic)
    end

    sign_in_as(accounts(:bob))
    patch forum_topic_path(topic), params: { forum_topic: { title: "Bob's now" } }
    assert_equal "My better ad", topic.reload.title

    sign_in_as(accounts(:wellkeeper))
    patch forum_topic_path(topic), params: { forum_topic: { pinned: "1", locked: "1" } }
    assert topic.reload.pinned?
    assert topic.locked?
    assert_difference -> { ForumTopic.count }, -1 do
      delete forum_topic_path(topic)
    end
  end

  test "pinned threads come first on the board" do
    old = ForumTopic.start!(board: @ads, account: accounts(:alice), title: "Pinned rules", body: "Read me")
    ForumTopic.start!(board: @ads, account: accounts(:alice), title: "Newer", body: "Hi")
    old.update!(pinned_at: Time.current)
    sign_in_as(accounts(:alice))
    get forum_board_path(@ads)
    assert_select ".forum-topic-row:first-child .forum-topic-row__title a", "Pinned rules"
  end

  test "posts can't carry scripts" do
    sign_in_as(accounts(:alice))
    post forum_board_forum_topics_path(@ads), params: { forum_topic: { title: "Sneaky", body: "<script>alert(1)</script> [x](javascript:alert(1))" } }
    get forum_topic_path(ForumTopic.last)
    assert_no_match(/<script>alert/, response.body)
    assert_no_match(/href="javascript:/, response.body)
  end
end

class Admin::ForumBoardsControllerTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper sets up a board and who can post" do
    sign_in_as(accounts(:wellkeeper))
    post admin_forum_boards_path, params: { forum_board: { name: "Plots", who_can_start: "senior_staff", who_can_reply: "staff" } }
    board = ForumBoard.find_by!(name: "Plots")
    assert_equal "senior_staff", board.who_can_start
    assert_not board.may_start_topic?(accounts(:builder))
    assert board.may_reply?(accounts(:builder))
    assert_not board.may_reply?(accounts(:alice))
  end

  test "\"nobody\" can't be chosen for starting threads" do
    sign_in_as(accounts(:wellkeeper))
    post admin_forum_boards_path, params: { forum_board: { name: "Empty", who_can_start: "nobody" } }
    assert_response :unprocessable_entity
  end

  test "a Scribe can manage boards too" do
    sign_in_as(accounts(:scribe))
    get admin_forum_boards_path
    assert_response :success
  end

  test "players and Pages are turned away" do
    [ :alice, :builder ].each do |name|
      sign_in_as(accounts(name))
      get admin_forum_boards_path
      assert_redirected_to root_path
    end
  end
end
