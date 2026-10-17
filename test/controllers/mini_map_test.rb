require "test_helper"

class MiniMapTest < ActionDispatch::IntegrationTest
  setup do
    area = rooms(:commons).area
    @north = Room.create!(name: "North Road", area: area, kind: "street")
    @main = Room.create!(name: "Main Street", area: area, kind: "street")
    @east = Room.create!(name: "East Lane", area: area, kind: "street")
    @shop = Room.create!(name: "The Bakery", area: area, kind: "building")
    Exit.create!(source_room: @main, destination_room: @north, direction: "N", kind: "street")
    Exit.create!(source_room: @north, destination_room: @main, direction: "S", kind: "street")
    Exit.create!(source_room: @main, destination_room: @east, direction: "E", kind: "street")
    Exit.create!(source_room: @main, destination_room: @shop, name: "The Bakery", kind: "building")
  end

  test "on a street the map shows the streets nearby and the street's buildings" do
    get room_path(@main)
    assert_select ".mini-map__street--centre .mini-map__label", text: "Main Street"
    assert_select ".mini-map__label", text: "North Road"
    assert_select ".mini-map__label", text: "East Lane"
    assert_select ".mini-map__label", text: "The Bakery", count: 0
    assert_select ".mini-map__place", text: "The Bakery"
    assert_equal 2, css_select(".mini-map__road").size
  end

  test "inside a building the map centres on the street outside" do
    get room_path(@shop)
    assert_select ".mini-map__street--centre .mini-map__label", text: "Main Street"
    assert_select ".mini-map__places", text: /Just off Main Street/
  end

  test "staff can switch the map off, and places away from streets have none" do
    get room_path(rooms(:garden))
    assert_select ".mini-map", count: 0
    GameSetting.current.update!(mini_map_enabled: false)
    get room_path(@main)
    assert_select ".mini-map", count: 0
  end
end
