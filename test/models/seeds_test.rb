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
