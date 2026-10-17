require "test_helper"

class StorytellerToolsTest < ActionDispatch::IntegrationTest
  setup do
    @scene = scenes(:duel)
    accounts(:bob).update!(storyteller: true)
    @scene.participant_for(characters(:sable)).update_column(:role, "storyteller")
    characters(:wren).soul_ratings.create!(trait: soul_skills(:wit), rating: 4)
  end

  test "the Storyteller calls for a roll and it rolls at once when the player has nothing to choose" do
    sign_in_as(accounts(:bob))
    get scene_path(@scene)
    assert_select ".storyteller-tools"
    assert_select ".storyteller-sheet__name", text: "Wren"
    assert_select ".storyteller-sheet__skills", text: /Wit 4/

    post scene_pending_rolls_path(@scene), params: { character_id: characters(:wren).id, skill_id: soul_skills(:wit).id, difficulty: "hard" }
    pending = @scene.pending_rolls.last
    assert_equal characters(:wren), pending.character
    assert pending.called?
    assert pending.rolled?
    assert @scene.poses.exists?(body: "The Storyteller calls for a Wit roll from Wren.")
    assert_equal 1, @scene.poses.roll.count
  end

  test "a called roll with optional Boons and Banes waits for the player" do
    bane = Soul::Bnb.create!(kind: "bane", name: "Hexed")
    entry = characters(:wren).add_bnb!(bane, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "staff")
    sign_in_as(accounts(:bob))
    get scene_path(@scene)
    assert_select "select[name='rulings[#{entry.id}]'][data-skill-ids='#{soul_skills(:wit).id}']"

    assert_no_difference -> { @scene.poses.roll.count } do
      post scene_pending_rolls_path(@scene), params: { character_id: characters(:wren).id, skill_id: soul_skills(:wit).id, difficulty: "hard", rulings: { entry.id.to_s => "choice" } }
    end
    assert @scene.pending_rolls.last.ready?
  end

  test "players who aren't the Storyteller can't call rolls or see the tools" do
    sign_in_as(accounts(:alice))
    get scene_path(@scene)
    assert_select ".storyteller-tools", count: 0
    post scene_pending_rolls_path(@scene), params: { character_id: characters(:sable).id, skill_id: soul_skills(:wit).id, difficulty: "hard" }
    assert_response :forbidden
    assert_empty @scene.pending_rolls
  end

  test "a Storyteller suggests XP, and it's only given when staff approve" do
    sign_in_as(accounts(:bob))
    post scene_award_suggestions_path(@scene), params: { character_id: characters(:wren).id, amount: 3, reason: "Faced the duel bravely." }
    suggestion = Soul::AwardSuggestion.last
    assert suggestion.pending?
    assert_equal 0, characters(:wren).xp_entries.count

    post scene_award_suggestions_path(@scene), params: { character_id: characters(:sable).id, amount: 3, reason: "Me!" }
    assert_equal 1, Soul::AwardSuggestion.count

    patch admin_soul_award_suggestion_path(suggestion), params: { decision: "approve" }
    assert suggestion.reload.pending?

    sign_in_as(accounts(:scribe))
    get admin_soul_reviews_path
    assert_select ".soul-reviews__item--award", text: /3 XP/
    patch admin_soul_award_suggestion_path(suggestion), params: { decision: "approve" }
    assert suggestion.reload.approved?
    assert_equal 3, characters(:wren).xp_entries.sum(:amount)
    assert_equal "Suggested by a Storyteller", characters(:wren).xp_entries.last.description
  end

  test "only the Chapter's Storyteller suggests XP, and staff can turn it down" do
    sign_in_as(accounts(:alice))
    post scene_award_suggestions_path(@scene), params: { character_id: characters(:sable).id, amount: 3, reason: "Friend bonus" }
    assert_response :forbidden

    sign_in_as(accounts(:bob))
    post scene_award_suggestions_path(@scene), params: { character_id: characters(:wren).id, amount: 50, reason: "Lots" }
    assert_equal 0, Soul::AwardSuggestion.count
    post scene_award_suggestions_path(@scene), params: { character_id: characters(:wren).id, amount: 2, reason: "Good scene" }

    sign_in_as(accounts(:scribe))
    patch admin_soul_award_suggestion_path(Soul::AwardSuggestion.last), params: { decision: "deny", reason: "Already rewarded" }
    assert Soul::AwardSuggestion.last.denied?
    assert_equal 0, characters(:wren).xp_entries.count
  end
end
