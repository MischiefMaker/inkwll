require "test_helper"

class ChapterTabsControllerTest < ActionDispatch::IntegrationTest
  test "every page shows the player's Chapters as tabs, with unread counts" do
    sign_in_as(accounts(:alice))
    get root_path

    assert_select ".chapter-tab", count: 2
    assert_select ".chapter-tab", text: /Duel at Dawn.*The Commons/m do
      assert_select ".chapter-tab__unread", text: "1"
      assert_select ".chapter-tab__turn", text: "Your turn"
    end
  end

  test "the tab bar can reload itself" do
    sign_in_as(accounts(:bob))
    get chapter_tabs_path
    assert_select "turbo-frame#chapter_tabs .chapter-tab", count: 2
  end

  test "reading a Chapter clears its unread count" do
    sign_in_as(accounts(:alice))
    patch scene_reading_path(scenes(:duel)), params: { up_to: 2 }, as: :json
    assert_response :no_content
    assert_equal 2, scene_participants(:duel_wren).reload.last_read_sequence
  end
end
