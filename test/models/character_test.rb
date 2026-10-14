require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  test "new characters start in the starting room" do
    character = accounts(:alice).characters.create!(name: "Fennel")
    assert_equal rooms(:commons), character.room
  end

  test "names are unique regardless of capitals" do
    character = accounts(:bob).characters.new(name: "wren")
    assert_not character.valid?
  end

  test "moves through an exit in its room" do
    wren = characters(:wren)
    wren.move_through(exits(:commons_north))
    assert_equal rooms(:hall), wren.reload.room
  end

  test "cannot use an exit from a different room" do
    assert_raises(ArgumentError) { characters(:wren).move_through(exits(:hall_south)) }
  end
end
