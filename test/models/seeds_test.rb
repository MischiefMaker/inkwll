require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "the starting map has a street in every small Area, with the buildings and outdoor spaces on it" do
    Rails.application.load_seed

    streets = Room.where(kind: "street")
    assert_equal 9, streets.count
    midtown = Room.find_by!(name: "Midtown Street")
    assert_equal %w[ outdoor building ], [ "Central Square", "The Lamplight Café" ].map { |n| Room.find_by!(name: n).kind }
    assert_includes midtown.exits.pluck(:name), "Central Square"
    assert_equal "S", midtown.exits.find_by!(name: "Downtown Street").direction
    assert_equal midtown, Area.find_by!(name: "City").entrance_room
    assert_equal Room.find_by!(name: "Central Square"), Room.find_by!(name: "Central Square").exits.find_by!(name: "Midtown Street").source_room
  end
end

class StarterStreetsTest < ActiveSupport::TestCase
  test "adds streets to an existing sample map once, and leaves other games alone" do
    assert_empty StarterStreets.install!, "a game without the sample places gets nothing"
    assert_equal 0, Room.where(kind: "street").count

    area = Area.create!(name: "Midtown")
    green = Room.create!(name: "Central Square", area: area)
    cafe = Room.create!(name: "The Lamplight Café", area: area)
    area.update!(entrance_room: green)

    assert_equal [ "Midtown Street" ], StarterStreets.install!.map(&:name)
    assert_no_difference [ "Room.count", "Exit.count" ] do
      StarterStreets.install!
    end
    street = Room.find_by!(name: "Midtown Street")
    assert_equal "outdoor", green.reload.kind
    assert_equal "building", cafe.reload.kind
    assert_equal street, area.reload.entrance_room
    assert_equal street, green.exits.find_by!(name: "Midtown Street").destination_room
  end
end
