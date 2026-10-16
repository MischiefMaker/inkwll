require "test_helper"

class SoulControllersTest < ActionDispatch::IntegrationTest
  test "the SOUL tab is only for the player and staff" do
    sign_in_as(accounts(:alice))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".soul-sheet__form"

    sign_in_as(accounts(:bob))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".soul-sheet", count: 0
    assert_select ".profile-menu__link", text: "SOUL", count: 0
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

  test "staff delete an unused Boon, but one characters hold is retired instead" do
    unused = Soul::Bnb.create!(kind: "boon", name: "Lucky")
    held = Soul::Bnb.create!(kind: "bane", name: "Cursed")
    Soul::CharacterBnb.insert!({ character_id: characters(:wren).id, soul_bnb_id: held.id, skill_ids: [ soul_skills(:strength).id ], source: "staff" })

    sign_in_as(accounts(:bob))
    delete admin_soul_bnb_path(unused)
    assert Soul::Bnb.exists?(unused.id), "players can't delete"

    sign_in_as(accounts(:wellkeeper))
    get admin_soul_bnbs_path
    assert_select ".bnb-catalogue__edit .icon--pencil"
    assert_select ".bnb-catalogue__delete .icon--trash"

    delete admin_soul_bnb_path(unused)
    assert_not Soul::Bnb.exists?(unused.id)
    delete admin_soul_bnb_path(held)
    assert_not held.reload.active?
  end

  test "staff write a guide to what the ratings mean, and the sheet shows it behind an i icon" do
    sign_in_as(accounts(:alice))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".rating-guide", count: 0

    sign_in_as(accounts(:bob))
    post admin_soul_rating_guides_path, params: { soul_rating_guide: { low: 9, high: 10, name: "Superhuman" } }
    assert_equal 0, Soul::RatingGuide.count, "players can't write it"

    sign_in_as(accounts(:wellkeeper))
    post admin_soul_rating_guides_path, params: { soul_rating_guide: { low: 9, high: 10, name: "Superhuman", description: "Beyond ordinary people." } }
    post admin_soul_rating_guides_path, params: { soul_rating_guide: { low: 7, high: 5, name: "Backwards" } }
    assert_equal [ "Superhuman" ], Soul::RatingGuide.pluck(:name)
    get admin_soul_path
    assert_select ".soul-admin__guide-item", text: /9–10.*Superhuman/m

    sign_in_as(accounts(:alice))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".rating-guide__button"
    assert_select ".rating-guide__popover .rating-guide__range", text: /9–10 Superhuman/
    assert_select ".rating-guide__about", text: "Beyond ordinary people."

    sign_in_as(accounts(:wellkeeper))
    delete admin_soul_rating_guide_path(Soul::RatingGuide.first)
    assert_equal 0, Soul::RatingGuide.count
  end
end
