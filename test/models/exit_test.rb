require "test_helper"

class ExitTest < ActiveSupport::TestCase
  test "a direction is optional, must be one of the 16 points, and names the Path if it has no name" do
    assert exits(:commons_north).valid?
    path = Exit.new(source_room: rooms(:garden), destination_room: rooms(:hall), direction: "nnw")
    assert path.valid?
    assert_equal "NNW", path.direction
    assert_equal "North-northwest", path.name
    assert_not Exit.new(source_room: rooms(:garden), destination_room: rooms(:hall), name: "Up", direction: "UP").valid?
  end

  test "one Path per direction in a Setting" do
    Exit.create!(source_room: rooms(:garden), destination_room: rooms(:hall), direction: "E")
    assert_not Exit.new(source_room: rooms(:garden), destination_room: rooms(:commons), name: "Gate", direction: "E").valid?
  end

  test "opposites and compass order" do
    assert_equal "SSE", Exit.opposite("NNW")
    assert_equal "W", Exit.opposite("E")
    a = Exit.new(name: "Zebra", direction: "S")
    b = Exit.new(name: "Apple")
    c = Exit.new(name: "Yard", direction: "N")
    assert_equal [ c, a, b ], Exit.in_compass_order([ b, a, c ])
  end
end
