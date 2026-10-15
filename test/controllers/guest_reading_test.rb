require "test_helper"

# Guests (not logged in) can read much of the game, but not write (owner,
# 2026-10-15): the boards, the wiki, Where, the directory and roster,
# profiles, the Archives and Chapters anyone may read.
class GuestReadingTest < ActionDispatch::IntegrationTest
  setup do
    @board = ForumBoard.create!(name: "News", who_can_start: "everyone", who_can_reply: "everyone")
    @topic = ForumTopic.start!(board: @board, account: accounts(:alice), title: "Welcome", body: "Hello, world.")
    GameSetting.current.update!(wiki_enabled: true)
    @page = WikiPage.create!(title: "House Rules", body: "Be kind.")
    scenes(:tea).update!(finished_at: 1.hour.ago)
  end

  test "guests can read the boards, the wiki, Where, the directory, roster, profiles and Archives" do
    [ forum_boards_path, forum_board_path(@board), forum_topic_path(@topic), wiki_pages_path, wiki_page_path(@page),
      where_path, directory_path, roster_path, archives_path, character_path(characters(:wren)),
      player_path(accounts(:alice).username), scene_path(scenes(:duel)), scene_path(scenes(:tea)), rooms_path,
      character_path(characters(:wren), tab: "logs"), character_path(characters(:wren), tab: "relationships"),
      character_path(characters(:wren), tab: "gallery"), character_path(characters(:wren), tab: "application") ].each do |path|
      get path
      assert_response :success, "#{path} should be open to guests"
      assert_select ".site-header--guest"
    end
  end

  test "the guest Menu links to everything guests can read" do
    get root_path
    [ where_path, archives_path, directory_path, roster_path, forum_boards_path, wiki_pages_path ].each do |path|
      assert_select ".site-header--guest .menu a[href=?]", path
    end
    assert_select ".site-header--guest .menu a[href=?]", characters_path, count: 0
  end

  test "guests see no way to post, and posting sends them to log in" do
    get forum_topic_path(@topic)
    assert_select "form[action*=posts]", count: 0
    get forum_board_path(@board)
    assert_select "a[href=?]", new_forum_board_forum_topic_path(@board), count: 0
    get wiki_page_path(@page)
    assert_select "a[href=?]", edit_wiki_page_path(@page), count: 0

    get new_forum_board_forum_topic_path(@board)
    assert_redirected_to new_session_path
    get edit_wiki_page_path(@page)
    assert_redirected_to new_session_path
    post wiki_pages_path, params: { wiki_page: { title: "Spam", body: "Spam" } }
    assert_redirected_to new_session_path
  end

  test "guests still can't see hidden Chapters or unapproved characters" do
    get scene_path(scenes(:secret))
    assert_response :not_found
  end
end
