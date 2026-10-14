require "test_helper"

class SoulControllersTest < ActionDispatch::IntegrationTest
  test "the SOUL tab is only for the player and staff" do
    sign_in_as(accounts(:alice))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".soul-sheet__form"

    sign_in_as(accounts(:bob))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".soul-sheet", count: 0
    assert_select ".profile-tabs__tab", text: "SOUL", count: 0
  end

  test "a player saves their starting sheet" do
    sign_in_as(accounts(:alice))
    patch character_sheet_path(characters(:wren)), params: { sheet: { resonance: "0",
      aspects: { soul_aspects(:mind).id => "2" }, skills: { soul_skills(:wit).id => "5" } } }
    assert_redirected_to character_path(characters(:wren), tab: "soul")
    assert_equal 5, characters(:wren).rating_for(soul_skills(:wit))

    patch character_sheet_path(characters(:wren)), params: { sheet: { resonance: "0", skills: { soul_skills(:wit).id => "9" } } }
    assert_match(/at most/, flash[:alert])
  end

  test "players can't change someone else's sheet" do
    sign_in_as(accounts(:bob))
    patch character_sheet_path(characters(:wren)), params: { sheet: { resonance: "0" } }
    assert_response :not_found
  end

  test "players finish their own sheet only when the game doesn't need approval, or once approved" do
    sign_in_as(accounts(:alice))
    GameSetting.current.update!(approval_required: true)
    characters(:wren).update!(status: "submitted")
    post character_sheet_lock_path(characters(:wren))
    assert characters(:wren).reload.sheet_open?

    GameSetting.current.update!(approval_required: false)
    post character_sheet_lock_path(characters(:wren))
    assert_not characters(:wren).reload.sheet_open?
  end

  test "players spend XP on their own character" do
    characters(:wren).lock_sheet!
    characters(:wren).award_xp!(3, source: "staff")
    sign_in_as(accounts(:alice))
    post character_xp_spends_path(characters(:wren), trait_type: "skill", trait_id: soul_skills(:wit).id)
    assert_equal 1, characters(:wren).rating_for(soul_skills(:wit))
    assert_equal 2, characters(:wren).xp_available
  end

  test "only staff give or take XP" do
    sign_in_as(accounts(:bob))
    post character_xp_entries_path(characters(:sable)), params: { amount: 5, note: "Me" }
    assert_response :forbidden
    assert_equal 0, characters(:sable).xp_available

    sign_in_as(accounts(:scribe))
    post character_xp_entries_path(characters(:sable)), params: { amount: 5, note: "Ran a plot" }
    post character_xp_entries_path(characters(:sable)), params: { amount: -2, note: "Typo" }
    assert_equal 3, characters(:sable).xp_available
    assert_equal accounts(:scribe), characters(:sable).xp_entries.first.actor
  end

  test "rolling in a Chapter posts the result" do
    sign_in_as(accounts(:alice))
    assert_difference -> { scenes(:duel).poses.roll.count } do
      post scene_rolls_path(scenes(:duel)), params: { skill_id: soul_skills(:strength).id, difficulty: "hard" }
    end
    assert_redirected_to scene_path(scenes(:duel))
    follow_redirect!
    assert_select ".pose--roll .pose__tag", text: "Roll"
    assert_select ".roll-details"
  end

  test "nothing SOUL works when the game switches it off" do
    GameSetting.current.update!(soul_enabled: false)
    sign_in_as(accounts(:alice))
    post scene_rolls_path(scenes(:duel)), params: { skill_id: soul_skills(:strength).id, difficulty: "hard" }
    assert_response :not_found
    get scene_path(scenes(:duel))
    assert_select ".roll-box", count: 0
    get character_path(characters(:wren), tab: "soul")
    assert_select ".soul-sheet", count: 0
  end

  test "Wellkeepers manage Aspects and Skills" do
    sign_in_as(accounts(:bob))
    get admin_soul_path
    assert_response :redirect

    sign_in_as(accounts(:wellkeeper))
    get admin_soul_path
    assert_select "h2", text: /Mind/
    post admin_soul_skills_path, params: { soul_skill: { name: "Sleight of Hand", soul_aspect_id: soul_aspects(:body).id } }
    assert Soul::Skill.find_by(key: "sleight_of_hand")
    delete admin_soul_aspect_path(soul_aspects(:body))
    assert Soul::Aspect.exists?(soul_aspects(:body).id), "an Aspect with Skills stays"
  end
end
