require "test_helper"

class GuestPreviewTest < ActionDispatch::IntegrationTest
  BROWSER = { "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) Firefox/130.0" }.freeze

  test "a guest can look at a Setting and walk its Paths as links" do
    get room_path(rooms(:commons)), headers: BROWSER
    assert_response :success
    assert_select ".from-afar__preview"
    assert_select "a.exit-link--preview[href=?]", room_path(exits(:commons_north).destination_room)
    assert_select "form[action=?]", room_travel_path(rooms(:commons)), 0
    assert_select ".room__save", 0
  end

  test "a guest can look at an Area" do
    get area_path(areas(:world)), headers: BROWSER
    assert_response :success
  end

  test "guests show under Here as Guest, then as a count" do
    get room_path(rooms(:commons)), headers: BROWSER
    assert_select ".room-here__guests", "Guest"

    open_session do |other|
      other.get room_path(rooms(:commons)), headers: BROWSER
      other.assert_select ".room-here__guests", "2 Guests"
    end

    sign_in_as(accounts(:alice))
    get room_path(rooms(:commons))
    assert_select ".room-here__guests", "2 Guests"
  end

  test "a guest counts in one Setting at a time" do
    get room_path(rooms(:commons)), headers: BROWSER
    get room_path(rooms(:garden)), headers: BROWSER
    assert_equal 0, GuestVisit.count_in(rooms(:commons))
    assert_equal 1, GuestVisit.count_in(rooms(:garden))
  end

  test "search engines aren't counted as guests" do
    get room_path(rooms(:commons)), headers: { "User-Agent" => "Googlebot/2.1" }
    assert_equal 0, GuestVisit.count_in(rooms(:commons))
  end

  test "guests still can't open Chapters, the directory or boards" do
    [ scene_path(Scene.first || Scene.create!(room: rooms(:commons), title: "Tea")), directory_path, forum_boards_path ].each do |path|
      get path, headers: BROWSER
      assert_redirected_to new_session_path
    end
  end

  test "a banned address can't preview" do
    Ban.create!(ip_range: "127.0.0.1", reason: "Spam", banned_by: accounts(:scribe))
    get root_path, headers: BROWSER
    assert_redirected_to new_session_path
  end
end
