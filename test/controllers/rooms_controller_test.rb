require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = accounts(:alice)
    sign_in_as(@alice)
  end

  test "a Setting shows its Area's short text above its name, when the Area has some" do
    get room_path(rooms(:commons))
    assert_select ".area-intro", count: 0

    areas(:world).update!(summary: "Where everything begins.")
    get room_path(rooms(:commons))
    assert_select ".area-intro__summary", text: /Where everything begins/
    assert_select ".area-intro + h1.page-title"
  end

  test "shows the room, its exits and who is here" do
    get room_path(rooms(:commons))

    assert_response :success
    assert_select "h1", "The Commons"
    assert_select "button.exit-link", "North"
    assert_select "a", "Sable"
  end

  test "exits can't be clicked when the active character is elsewhere" do
    get room_path(rooms(:garden))
    assert_select "button.exit-link", count: 0
  end

  test "remembers the active character for the room" do
    get room_path(rooms(:commons))
    assert_equal characters(:wren), @alice.remembered_character_for(rooms(:commons))
  end

  test "switches back to the character last used in this room" do
    @alice.remember_character(characters(:moth), rooms(:hall))

    get room_path(rooms(:hall))

    assert_equal characters(:moth), @alice.reload.active_character
  end

  test "does not switch to a remembered character who has since left" do
    @alice.remember_character(characters(:moth), rooms(:garden))

    get room_path(rooms(:garden))

    assert_equal characters(:wren), @alice.reload.active_character
  end

  test "numbered Paths show as a compact list in number order, apart from the other Paths" do
    commons = rooms(:commons)
    commons.update!(kind: "apartments")
    Exit.create!(source_room: commons, destination_room: rooms(:garden), number: "101", name: "Nestor Nash")
    Exit.create!(source_room: commons, destination_room: rooms(:tower), number: "20", name: "Jaxon Marley")

    get room_path(commons)

    assert_select ".numbered-paths__title", /Apartments/
    assert_select "button.numbered-path", count: 2
    assert_select ".numbered-path__number", count: 2 do |numbers|
      assert_equal %w[ 20 101 ], numbers.map(&:text)
    end
    assert_select "button.exit-link", "North"
    assert_select "button.exit-link", text: /Nestor/, count: 0
  end

  test "rooms behind numbered doors are left out of an Area's list" do
    Exit.create!(source_room: rooms(:garden), destination_room: rooms(:tower), number: "1", name: "Tower flat")
    get area_path(areas(:castle))
    assert_select ".board__name", text: "Garden"
    assert_select ".board__name", text: "Tower", count: 0
  end
end
