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

  test "compass points are for streets; buildings and units come back Out" do
    assert_not Exit.new(source_room: rooms(:garden), destination_room: rooms(:hall), name: "Shop", kind: "building", direction: "N").valid?
    assert Exit.new(source_room: rooms(:garden), destination_room: rooms(:hall), kind: "street", direction: "OUT").valid?
    assert_equal "OUT", Exit.opposite(nil, kind: "building")
    assert_equal "OUT", Exit.opposite(nil, kind: "unit")
    assert_nil Exit.opposite(nil)
    assert_nil Exit.opposite("OUT")
    assert_not Exit.new(source_room: rooms(:garden), destination_room: rooms(:hall), name: "x", kind: "tunnel").valid?
  end

  test "a Path with a door number is a unit, and a unit needs a number" do
    path = Exit.create!(source_room: rooms(:garden), destination_room: rooms(:hall), name: "Jaxon Marley", number: "100")
    assert_equal "unit", path.kind
    assert_not Exit.new(source_room: rooms(:garden), destination_room: rooms(:hall), name: "Flat", kind: "unit").valid?
  end
end
