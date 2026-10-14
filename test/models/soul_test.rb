require "test_helper"

class SoulTest < ActiveSupport::TestCase
  # Hands out the given numbers in order, in place of real dice.
  class LoadedDice
    def initialize(*values) = @values = values
    def rand(_range) = @values.shift
  end

  test "advancement costs follow SOUL's formula" do
    assert_equal 1, Soul::Rules.cost(new_rating: 1, xp_spent: 0, resonance: 0)
    assert_equal 13, Soul::Rules.cost(new_rating: 5, xp_spent: 0, resonance: 0)
    assert_equal 8, Soul::Rules.cost(new_rating: 2, xp_spent: 0, resonance: 0, aspect: true)
    assert_equal 29, Soul::Rules.cost(new_rating: 5, xp_spent: 0, resonance: 1)
    assert_equal 12, Soul::Rules.cost(new_rating: 5, xp_spent: 0, resonance: -1)
    assert_operator Soul::Rules.cost(new_rating: 5, xp_spent: 500, resonance: 0), :>, 13
  end

  test "margins become degrees of success" do
    assert_equal "exceptional_success", Soul::Rules.degree_for(10)
    assert_equal "success", Soul::Rules.degree_for(0)
    assert_equal "complicated_success", Soul::Rules.degree_for(-1)
    assert_equal "lucky_failure", Soul::Rules.degree_for(-6)
    assert_equal "failure", Soul::Rules.degree_for(-11)
    assert_equal "catastrophic_failure", Soul::Rules.degree_for(-21)
  end

  test "double 20s explode and double 1s implode" do
    assert_equal({ total: 47, mode: "explosion", segments: [ [ 20, 20 ], [ 3, 4 ] ] }, Soul::Dice.roll(0, random: LoadedDice.new(20, 20, 3, 4)))
    assert_equal({ total: -5, mode: "implosion", segments: [ [ 1, 1 ], [ 3, 4 ] ] }, Soul::Dice.roll(0, random: LoadedDice.new(1, 1, 3, 4)))
    assert_equal 9, Soul::Dice.roll(0, random: LoadedDice.new(4, 5))[:total]
  end

  test "the chance of success is worked out exactly" do
    even = Soul::Dice.success_probability(0, 21)
    assert_in_delta 0.525, even, 0.01
    assert_operator Soul::Dice.success_probability(0, 30), :<, even
    assert_in_delta 1.0, Soul::Dice.success_probability(0, -100), 0.0001
  end

  test "the starting sheet stays within the points and the cap" do
    wren = characters(:wren)
    wren.set_starting_sheet!(resonance: 1, aspects: { soul_aspects(:mind).id.to_s => 3 }, skills: { soul_skills(:wit).id.to_s => 8 })
    assert_equal 1, wren.resonance
    assert_equal 8, wren.rating_for(soul_skills(:wit))
    assert_equal 9, wren.roll_base(soul_skills(:wit)) # 8 + Mind 3 × 0.2

    assert_raises(Character::SoulSheet::SheetError) { wren.set_starting_sheet!(resonance: 0, skills: { soul_skills(:wit).id.to_s => 8 }) }
    assert_raises(Character::SoulSheet::SheetError) { wren.set_starting_sheet!(resonance: 0, aspects: { soul_aspects(:mind).id.to_s => 6 }) }
    assert_raises(Character::SoulSheet::SheetError) { wren.set_starting_sheet!(resonance: 9) }

    wren.lock_sheet!
    assert_raises(Character::SoulSheet::SheetError) { wren.set_starting_sheet!(resonance: 0) }
  end

  test "spending XP raises a rating by one" do
    wren = characters(:wren)
    wren.lock_sheet!
    wren.award_xp!(5, source: "staff")
    wren.spend_xp!(soul_skills(:wit))
    assert_equal 1, wren.rating_for(soul_skills(:wit))
    assert_equal 4, wren.xp_available
    assert_equal 1, wren.xp_spent

    assert_raises(Character::SoulSheet::SheetError) { 3.times { wren.spend_xp!(soul_aspects(:mind)) } }
  end

  test "an award with the same key only counts once" do
    wren = characters(:wren)
    2.times { wren.award_xp!(1, source: "weekly", key: "weekly:test:#{wren.id}") }
    assert_equal 1, wren.xp_available
  end

  test "characters behind the median catch up" do
    %i[ wren sable finch ].each { |name| characters(name).award_xp!(10, source: "staff") }
    moth = characters(:moth)
    moth.award_xp!(1, source: "weekly", catchup: true)
    assert_equal 2, moth.xp_available
    characters(:wren).award_xp!(1, source: "weekly", catchup: true)
    assert_equal 11, characters(:wren).xp_available
  end

  test "approval locks the sheet" do
    character = accounts(:alice).characters.create!(name: "Newcomer", status: "submitted")
    assert character.sheet_open?
    character.approve!(by: accounts(:scribe))
    assert_not character.sheet_open?
  end

  test "finishing a Chapter gives XP to the characters who posted, once" do
    scene = scenes(:duel)
    scene.finish!(by: characters(:wren))
    assert_equal 1, characters(:wren).xp_available
    assert_equal 1, characters(:sable).xp_available

    scene.reopen!(by: characters(:wren))
    scene.finish!(by: characters(:wren))
    assert_equal 1, characters(:wren).xp_available
  end

  test "a roll is posted to the Chapter without taking the turn" do
    scene = scenes(:duel)
    turn = scene.current_turn_participant
    pose = scene.roll!(characters(:sable), soul_skills(:wit), "standard")
    assert pose.roll?
    assert_match(/Sable rolls Wit against Standard \(13\)/, pose.body)
    assert_equal pose, Soul::Roll.last.pose
    assert_equal turn, scene.reload.current_turn_participant
    assert_raises(ActiveRecord::RecordInvalid) { pose.edit!("I got a 40 really") }
  end
end
