require "test_helper"
require Rails.root.join("db/migrate/20261015230001_start_goal_inklings_for_approved_characters.rb")
require Rails.root.join("db/migrate/20261016030000_show_application_inklings_to_staff.rb")
require Rails.root.join("db/migrate/20261016000002_rename_application_inklings.rb")

# The one-time catch-ups live in their migrations; these tests run them directly.

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

    assert_equal 1, StartGoalInklingsForApprovedCharacters.new.start!
    assert_equal "goal", field.reload.inkling_kind
    assert_equal "secret", secrets.reload.inkling_kind
    assert_equal "progress", chosen.reload.inkling_kind, "a choice already made is kept"
    goal = Inkling.find_by!(character: wren, kind: "goal")
    assert_equal "Wren's First Goal", goal.title
    assert_equal wren.account, goal.creator
    assert_equal "Win the Ravens' trust.", goal.entries.first.body
    assert_not Inkling.exists?(character: moth, kind: "goal")

    assert_equal 0, StartGoalInklingsForApprovedCharacters.new.start!
    assert_equal 1, Inkling.where(character: wren, kind: "goal").count
  end

  test "Inklings made from an application are shown to staff, and the catch-up fixes older ones" do
    field = ProfileField.create!(name: "Goals", section: "application", field_type: "long_text", public: false, inkling_kind: "goal")
    wren = characters(:wren)
    wren.update!(status: "approved")
    wren.profile_values.create!(profile_field: field, value: "Win.")
    wren.start_inklings_from_profile!
    assert Inkling.find_by!(character: wren, kind: "goal").staff_visible_at
    own = Inkling.start!(character: wren, by: wren.account, kind: "goal", title: "My secret plan", body: "Shh.")
    assert_nil own.staff_visible_at, "a player's own draft stays private"

    old = Inkling.find_by!(character: wren, kind: "goal")
    old.update_columns(staff_visible_at: nil)
    assert_equal 1, ShowApplicationInklingsToStaff.new.show!
    assert old.reload.staff_visible_at
    assert_nil own.reload.staff_visible_at
  end

  test "Inklings already titled with just the field name get the First Goal title" do
    field = ProfileField.create!(name: "Goals", section: "application", field_type: "long_text", public: false, inkling_kind: "goal")
    wren = characters(:wren)
    old = Inkling.start!(character: wren, by: wren.account, kind: "goal", title: "Goals", body: "Win.")
    assert_equal 1, RenameApplicationInklings.new.rename!
    assert_equal "Wren's First Goal", old.reload.title
    assert_equal 0, RenameApplicationInklings.new.rename!
  end

  test "a Boon or Bane can affect no Skill" do
    bnb = Soul::Bnb.create!(kind: "boon", name: "Lucky Charm", skill_ids: [])
    entry = characters(:wren).add_bnb!(bnb, level: "minor", skill_ids: [], explanation: "Just lucky.", source: "staff")
    assert entry.persisted?
    assert_empty entry.skills
  end

  test "an unapproved character can't start an Inkling" do
    draft = accounts(:alice).characters.create!(name: "Not Yet", status: "draft")
    assert_raises(ArgumentError) do
      Inkling.start!(character: draft, by: accounts(:alice), kind: "goal", title: "Too soon", body: "Hm.")
    end
  end
end
