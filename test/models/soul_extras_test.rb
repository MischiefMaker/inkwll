require "test_helper"

class SoulExtrasTest < ActiveSupport::TestCase
  setup do
    @contacts = Soul::Bnb.create!(kind: "boon", name: "Contacts", skill_ids: [ soul_skills(:wit).id ])
    @luck = Soul::Bnb.create!(kind: "boon", name: "Lucky")
    @cursed = Soul::Bnb.create!(kind: "bane", name: "Cursed")
    @wren = characters(:wren)
  end

  test "a Boon needs enough Banes beside it" do
    @wren.add_bnb!(@contacts, level: "minor", skill_ids: [], explanation: "", source: "starting")
    error = assert_raises(Character::SoulSheet::SheetError) do
      @wren.add_bnb!(@luck, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
    end
    assert_match(/Bane/, error.message)

    @wren.add_bnb!(@cursed, level: "minor", skill_ids: [ soul_skills(:strength).id ], explanation: "", source: "starting")
    @wren.add_bnb!(@luck, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
    assert_equal 3, @wren.active_bnbs.size
  end

  test "starting sheets follow the Resonance limits" do
    @wren.update!(resonance: -2)
    assert_raises(Character::SoulSheet::SheetError) do
      @wren.add_bnb!(@cursed, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
      @wren.add_bnb!(@contacts, level: "minor", skill_ids: [], explanation: "", source: "starting")
    end
    assert_raises(Character::SoulSheet::SheetError) do
      @wren.add_bnb!(@cursed, level: "legendary", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
      @wren.add_bnb!(@cursed, level: "legendary", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
      @wren.add_bnb!(@cursed, level: "legendary", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
    end
  end

  test "Boons and Banes for the Skill change the roll" do
    @wren.add_bnb!(@cursed, level: "major", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "staff")
    @wren.add_bnb!(@contacts, level: "legendary", skill_ids: [], explanation: "", source: "staff")
    roll = @wren.roll_skill(soul_skills(:wit), "standard")
    assert_equal 1, roll.net_modifier
    assert_equal [ "Cursed", "Contacts" ].sort, roll.applied.map { |a| a["name"] }.sort
    assert_equal 0, @wren.roll_skill(soul_skills(:strength), "standard").net_modifier
  end

  test "progress makes a Boon stronger and a Bane weaker, and it all goes in the history" do
    boon = @wren.add_bnb!(@cursed, level: "major", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "staff")
    @wren.change_bnb!(boon, "progress", actor: accounts(:scribe))
    assert_equal "minor", boon.reload.level
    @wren.change_bnb!(boon, "resolve", actor: accounts(:scribe), reason: "Curse lifted")
    assert boon.reload.resolved?
    assert_equal 0, @wren.roll_skill(soul_skills(:wit), "standard").net_modifier
    assert_equal 3, @wren.history_entries.count
    assert_equal "Curse lifted", Soul::AuditEntry.where(character: @wren).newest_first.first.reason
  end

  test "locking the sheet starts the history with the starting Boons and Banes" do
    @wren.add_bnb!(@cursed, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "starting")
    assert_empty @wren.history_entries
    @wren.lock_sheet!
    assert_equal [ "Began play with Resonance 0.", "Began with Cursed (Minor)." ].sort, @wren.history_entries.pluck(:narrative).sort
  end

  test "the Storyteller judges a waiting roll" do
    scene = scenes(:duel)
    scene.participant_for(characters(:sable)).update_column(:role, "storyteller")
    entry = @wren.add_bnb!(@cursed, level: "minor", skill_ids: [ soul_skills(:strength).id ], explanation: "", source: "staff")

    pending = scene.ask_storyteller_to_roll!(@wren, soul_skills(:wit), "standard")
    assert_raises(ArgumentError) { scene.ask_storyteller_to_roll!(@wren, soul_skills(:wit), "standard") }
    assert_raises(ArgumentError) { scene.judge_roll!(pending, by: @wren, difficulty_name: "easy", bnb_ids: []) }

    pose = scene.judge_roll!(pending, by: characters(:sable), difficulty_name: "hard", bnb_ids: [ entry.id ])
    assert pending.reload.rolled?
    assert_match(/against Hard \(21\) as judged by Sable with Cursed/, pose.body)
    assert_equal(-1, pose.soul_roll.net_modifier)
  end
end
