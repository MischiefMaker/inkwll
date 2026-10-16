require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "age comes from the birthday and the game's date" do
    freeze_time
    GameSetting.current.update!(ic_today: "1890-06-01", ic_days_per_day: 1)
    character = characters(:wren)
    character.update!(profile: { profile_fields(:birthday).id => "1870-07-15" })
    assert_equal 19, character.age

    travel 60.days do
      assert_equal 20, character.reload.age
    end
  end

  test "a faster game clock ages characters faster" do
    freeze_time
    GameSetting.current.update!(ic_today: "1890-01-01", ic_days_per_day: 3)
    travel 10.days do
      assert_equal Date.new(1890, 1, 31), IcClock.today
    end
  end

  test "dates must be dates" do
    character = characters(:wren)
    assert_not character.update(profile: { profile_fields(:birthday).id => "not a date" })
  end

  test "new characters need approval before joining Chapters, when the game asks for it" do
    character = accounts(:alice).characters.create!(name: "Newbie")
    assert character.draft?
    assert_raises(ArgumentError) { Scene.start!(character: character, title: "Too soon") }

    assert_not character.submit!, "Hometown is required"
    character.update!(profile: { profile_fields(:hometown).id => "London" })
    character.set_starting_sheet!(resonance: 0, skills: { soul_skills(:wit).id.to_s => 1 })
    assert character.submit!
    assert character.submitted?

    character.approve!(by: accounts(:scribe))
    assert character.can_play?
    assert Scene.start!(character: character, title: "Now")
  end

  test "games without approval skip it" do
    GameSetting.current.update!(approval_required: false)
    assert accounts(:alice).characters.create!(name: "Easy").approved?
  end

  test "relationships link to characters by name, or keep a plain name" do
    linked = characters(:wren).relationships.create!(other_character_name: "sable", kind: "rival")
    assert_equal characters(:sable), linked.other_character
    npc = characters(:wren).relationships.create!(other_character_name: "Old Tom", kind: "family")
    assert_equal "Old Tom", npc.other_label
  end
end
