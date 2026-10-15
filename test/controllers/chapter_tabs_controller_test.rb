require "test_helper"

class ChapterTabsControllerTest < ActionDispatch::IntegrationTest
  test "every page shows the player's Chapters as tabs, with unread counts" do
    sign_in_as(accounts(:alice))
    get root_path

    assert_select ".chapter-tab", count: 2
    assert_select ".chapter-tab", text: /Duel at Dawn.*The Commons/m do
      assert_select ".chapter-tab__unread", text: "1"
      assert_select ".chapter-tab__turn", text: "Your turn"
      assert_select ".chapter-tab__badges .chapter-tab__quill"
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

  test "the tab bar can fold away, and flags a waiting turn" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".chapter-tabs__toggle"
    assert_select ".chapter-tabs__turn-flag"
  end

  test "a finished Chapter's tab can be closed, and only by its own player" do
    scenes(:duel).finish!(by: characters(:wren))
    participant = scene_participants(:duel_wren)

    sign_in_as(accounts(:bob))
    delete close_chapter_tab_path(participant)
    assert_response :not_found
    assert_not participant.reload.tab_closed?

    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".chapter-tab__close", count: 1
    delete close_chapter_tab_path(participant)
    assert participant.reload.tab_closed?
    get root_path
    assert_select ".chapter-tab", text: /Duel at Dawn/, count: 0
  end

  test "a Chapter that's still going has no close button and can't be closed" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".chapter-tab__close", count: 0
    delete close_chapter_tab_path(scene_participants(:duel_wren))
    assert_not scene_participants(:duel_wren).reload.tab_closed?
  end

  test "reopening a finished Chapter brings its tab back" do
    scenes(:duel).finish!(by: characters(:wren))
    scene_participants(:duel_wren).update!(tab_closed: true)
    scenes(:duel).reopen!(by: characters(:wren))
    assert_not scene_participants(:duel_wren).reload.tab_closed?
  end

  test "the quill shows beside the places where it's your turn" do
    accounts(:alice).update!(active_character: characters(:wren))
    sign_in_as(accounts(:alice))
    commons = rooms(:commons)

    get root_path
    assert_select ".where-now .turn-quill"
    assert_select ".place__name .turn-quill", minimum: 1

    get rooms_path
    assert_select ".room-index__room a[href=?] + a.turn-quill[href=?]", room_path(commons), scene_path(scenes(:duel))

    get area_path(commons.area)
    assert_select ".board__row .turn-quill", minimum: 1

    sign_in_as(accounts(:bob))
    scenes(:duel).update_columns(paused_at: Time.current)
    get rooms_path
    assert_select ".turn-quill", count: 0
  end

  test "My Characters is sectioned by Group, with icons and the quill on the character whose turn it is" do
    ravens = CharacterGroup.create!(name: "Ravens", colour: "#336699")
    characters(:wren).update!(character_group: ravens)
    sign_in_as(accounts(:alice))

    get characters_path
    assert_select ".my-characters__group .my-characters__heading", text: "Ravens"
    assert_select ".my-characters__group--none .my-characters__heading", text: "No group"
    assert_select ".my-characters__item .character-icon", minimum: 2
    assert_select ".my-characters__item", text: /Wren/ do
      assert_select "a.turn-quill[href=?]", scene_path(scenes(:duel))
    end
    assert_select ".my-characters__item", text: /Moth/ do
      assert_select ".turn-quill", count: 0
    end
  end
end
