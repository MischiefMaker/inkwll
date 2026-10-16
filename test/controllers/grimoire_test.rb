require "test_helper"

class GrimoireTest < ActionDispatch::IntegrationTest
  setup do
    GameSetting.current.update!(grimoire_enabled: true)
    @branch = Grimoire::Branch.create!(name: "Hedgecraft", skill: soul_skills(:wit))
    @spell = @branch.spells.create!(name: "Will-o'-wisp", minimum_rating: 2, difficulty_name: "standard")
    @wren = characters(:wren)
    @wren.lock_sheet!
    @wren.soul_ratings.create!(trait: soul_skills(:wit), rating: 3)
    @wren.award_xp!(5, source: "staff")
    accounts(:alice).update!(active_character: @wren)
  end

  test "a player learns a spell with XP once their Skill is high enough" do
    sign_in_as(accounts(:alice))
    post character_spells_path(@wren), params: { spell_id: @spell.id }
    assert @wren.knows_spell?(@spell)
    assert_equal 3, @wren.xp_available
    assert_equal "Learned the spell Will-o'-wisp", @wren.xp_entries.where(kind: "spend").last.description
  end

  test "a spell out of reach can't be learned" do
    hard = @branch.spells.create!(name: "Storm Call", minimum_rating: 5)
    sign_in_as(accounts(:alice))
    post character_spells_path(@wren), params: { spell_id: hard.id }
    assert_not @wren.knows_spell?(hard)
    assert_equal 5, @wren.xp_available
  end

  test "players can't learn spells for someone else's character" do
    sign_in_as(accounts(:bob))
    post character_spells_path(@wren), params: { spell_id: @spell.id }
    assert_response :not_found
    assert_not @wren.knows_spell?(@spell)
  end

  test "the Cast a spell box shows on a Chapter even before any spell is learned" do
    sign_in_as(accounts(:alice))
    get scene_path(scenes(:duel))
    assert_select ".cast-box__empty"
    @wren.learn_spell!(@spell)
    get scene_path(scenes(:duel))
    assert_select ".cast-box__form"
  end

  test "casting a learned spell posts a roll in the Chapter" do
    @wren.learn_spell!(@spell)
    sign_in_as(accounts(:alice))
    assert_difference "scenes(:duel).poses.count" do
      post scene_casts_path(scenes(:duel)), params: { spell_id: @spell.id }
    end
    assert_match "Wren casts Will-o'-wisp", scenes(:duel).poses.last.body
  end

  test "you can't cast a spell you haven't learned" do
    sign_in_as(accounts(:alice))
    assert_no_difference "scenes(:duel).poses.count" do
      post scene_casts_path(scenes(:duel)), params: { spell_id: @spell.id }
    end
  end

  test "a player proposes a spell and staff approve it" do
    sign_in_as(accounts(:alice))
    post character_spell_proposals_path(@wren), params: { grimoire_proposal: { branch_id: @branch.id, name: "Hearthward", description: "Keeps a home safe.", minimum_rating: 1, difficulty_name: "easy" } }
    proposal = Grimoire::Proposal.last
    assert proposal.pending?

    patch admin_grimoire_proposal_path(proposal), params: { decision: "approve" }
    assert proposal.reload.pending?

    sign_in_as(accounts(:scribe))
    patch admin_grimoire_proposal_path(proposal), params: { decision: "approve" }
    assert proposal.reload.approved?
    assert @branch.spells.exists?(name: "Hearthward")
  end

  test "only App staff manage branches and spells" do
    sign_in_as(accounts(:alice))
    post admin_grimoire_spells_path, params: { grimoire_spell: { branch_id: @branch.id, name: "Sneaky", minimum_rating: 0, difficulty_name: "easy" } }
    assert_redirected_to root_path

    sign_in_as(accounts(:scribe))
    post admin_grimoire_spells_path, params: { grimoire_spell: { branch_id: @branch.id, name: "Glamour", minimum_rating: 1, difficulty_name: "easy" } }
    assert @branch.spells.exists?(name: "Glamour")
    get admin_grimoire_path
    assert_response :success
  end

  test "Grimoire is off until a game switches it on" do
    GameSetting.current.update!(grimoire_enabled: false)
    sign_in_as(accounts(:alice))
    post character_spells_path(@wren), params: { spell_id: @spell.id }
    assert_response :not_found
  end

  test "the Grimoire tab shows known and learnable spells" do
    sign_in_as(accounts(:alice))
    get character_path(@wren, tab: "grimoire")
    assert_select ".grimoire-spell__name", text: /Will-o'-wisp/
    assert_select "button", text: "Learn for 2 XP"
  end

  test "casting a learned spell in an Inkling adds a roll entry" do
    @wren.learn_spell!(@spell)
    sign_in_as(accounts(:alice))
    inkling = Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Light the way", body: "Somehow.")
    get inkling_path(inkling)
    assert_select ".inkling__cast form"
    assert_difference "inkling.entries.count" do
      post inkling_casts_path(inkling), params: { spell_id: @spell.id, private: "1" }
    end
    assert_match "Wren casts Will-o'-wisp", inkling.entries.last.body
    assert inkling.entries.last.private?
  end

  test "you can't cast an unlearned spell, or in someone else's Inkling" do
    inkling = Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Light the way", body: "Somehow.")
    sign_in_as(accounts(:alice))
    assert_no_difference "inkling.entries.count" do
      post inkling_casts_path(inkling), params: { spell_id: @spell.id }
    end
    @wren.learn_spell!(@spell)
    sign_in_as(accounts(:bob))
    assert_no_difference "inkling.entries.count" do
      post inkling_casts_path(inkling), params: { spell_id: @spell.id }
    end
  end
end
