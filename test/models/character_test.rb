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

  test "character names can use spaces and special characters" do
    character = accounts(:alice).characters.create!(name: "Mary-Jane O'Neil (the 2nd)")
    assert_equal "Mary-Jane O'Neil (the 2nd)", character.name
  end

  test "the catch-up gives approved characters a Goal Inkling from their Goals answer, once" do
    field = ProfileField.create!(name: "Goals", section: "application", field_type: "long_text", public: false, position: 0)
    wren = characters(:wren)
    wren.update!(status: "approved")
    wren.profile_values.create!(profile_field: field, value: "Win the Ravens' trust.")
    moth = characters(:moth)
    moth.update!(status: "draft")
    moth.profile_values.create!(profile_field: field, value: "Not approved yet.")

    secrets = ProfileField.create!(name: "Secrets", section: "application", field_type: "long_text", public: false, position: 1)
    chosen = ProfileField.create!(name: "Goals", section: "demographics", field_type: "text", public: false, position: 2, inkling_kind: "progress")

    assert_equal 1, Character.start_goal_inklings!
    assert_equal "goal", field.reload.inkling_kind
    assert_equal "secret", secrets.reload.inkling_kind
    assert_equal "progress", chosen.reload.inkling_kind, "a choice already made is kept"
    goal = Inkling.find_by!(character: wren, kind: "goal")
    assert_equal "Goals", goal.title
    assert_equal wren.account, goal.creator
    assert_equal "Win the Ravens' trust.", goal.entries.first.body
    assert_not Inkling.exists?(character: moth, kind: "goal")

    assert_equal 0, Character.start_goal_inklings!
    assert_equal 1, Inkling.where(character: wren, kind: "goal").count
  end
end
