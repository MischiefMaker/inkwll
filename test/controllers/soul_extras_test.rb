require "test_helper"

class SoulExtrasControllersTest < ActionDispatch::IntegrationTest
  setup do
    @cursed = Soul::Bnb.create!(kind: "bane", name: "Cursed", description: "Under a curse")
  end

  test "players pick Boons and Banes only on their own open sheet" do
    sign_in_as(accounts(:alice))
    post character_bnbs_path(characters(:wren)), params: { bnb_id: @cursed.id, level: "minor", skill_ids: [ soul_skills(:wit).id ] }
    assert_equal 1, characters(:wren).character_bnbs.count

    characters(:wren).lock_sheet!
    post character_bnbs_path(characters(:wren)), params: { bnb_id: @cursed.id, level: "minor", skill_ids: [ soul_skills(:wit).id ] }
    assert_response :forbidden

    sign_in_as(accounts(:bob))
    post character_bnbs_path(characters(:moth)), params: { bnb_id: @cursed.id, level: "minor", skill_ids: [ soul_skills(:wit).id ] }
    assert_response :forbidden
  end

  test "after locking, players ask and staff approve" do
    characters(:wren).lock_sheet!
    sign_in_as(accounts(:alice))
    post character_bnb_requests_path(characters(:wren)), params: { bnb_id: @cursed.id, level: "major", skill_ids: [ soul_skills(:wit).id ], explanation: "She opened the box." }
    request = Soul::BnbRequest.last
    assert request.pending?

    patch admin_soul_review_path(request), params: { decision: "approve" }
    assert request.reload.pending?, "players can't approve"

    sign_in_as(accounts(:scribe))
    get admin_soul_reviews_path
    assert_select ".soul-reviews__item", text: /Wren asks for/
    patch admin_soul_review_path(request), params: { decision: "approve" }
    assert request.reload.approved?
    assert_equal "major", characters(:wren).character_bnbs.last.level
  end

  test "only staff change a character's Boons and Banes" do
    entry = characters(:wren).add_bnb!(@cursed, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "", source: "staff")
    sign_in_as(accounts(:alice))
    patch character_bnb_path(characters(:wren), entry), params: { change: "resolve" }
    assert_response :forbidden

    sign_in_as(accounts(:scribe))
    patch character_bnb_path(characters(:wren), entry), params: { change: "resolve", reason: "Done" }
    assert entry.reload.resolved?
  end

  test "Culminations are proposed by the player and approved by staff" do
    sign_in_as(accounts(:bob))
    post character_culminations_path(characters(:wren)), params: { title: "Not mine" }
    assert_response :not_found

    sign_in_as(accounts(:alice))
    post character_culminations_path(characters(:wren)), params: { title: "Took the oath", description: "At the old well." }
    culmination = Soul::Culmination.last
    patch character_culmination_path(characters(:wren), culmination), params: { decision: "approved" }
    assert_response :forbidden

    sign_in_as(accounts(:scribe))
    patch character_culmination_path(characters(:wren), culmination), params: { decision: "approved" }
    assert culmination.reload.approved?
    assert_includes characters(:wren).history_entries.pluck(:narrative), "Reached a Culmination: Took the oath."
  end

  test "staff manage the catalogue" do
    sign_in_as(accounts(:alice))
    post admin_soul_bnbs_path, params: { soul_bnb: { kind: "boon", name: "Contacts" } }
    assert_not Soul::Bnb.exists?(name: "Contacts")

    sign_in_as(accounts(:scribe))
    post admin_soul_bnbs_path, params: { soul_bnb: { kind: "boon", name: "Contacts", skill_ids: [ "", soul_skills(:wit).id.to_s ] } }
    assert_equal [ soul_skills(:wit).id ], Soul::Bnb.find_by(name: "Contacts").skill_ids
  end

  test "players ask the Storyteller and the Storyteller rolls it" do
    scene = scenes(:duel)
    scene.participant_for(characters(:sable)).update_column(:role, "storyteller")
    sign_in_as(accounts(:alice))
    post scene_rolls_path(scene), params: { skill_id: soul_skills(:wit).id, difficulty: "standard", ask_storyteller: "1" }
    pending = scene.pending_rolls.waiting.last
    assert pending

    patch scene_pending_roll_path(scene, pending), params: { difficulty: "easy" }
    assert_response :forbidden

    sign_in_as(accounts(:bob))
    get scene_path(scene)
    assert_select ".pending-roll__form"
    assert_difference -> { scene.poses.roll.count } do
      patch scene_pending_roll_path(scene, pending), params: { difficulty: "easy" }
    end
    assert pending.reload.rolled?
  end

  test "the SOUL tab shows Boons and Banes, Culminations and history" do
    characters(:wren).add_bnb!(@cursed, level: "minor", skill_ids: [ soul_skills(:wit).id ], explanation: "Family curse", source: "staff")
    sign_in_as(accounts(:alice))
    get character_path(characters(:wren), tab: "soul")
    assert_select ".soul-bnb__name", text: "Cursed"
    assert_select ".soul-bnb__explanation", text: /Family curse/
    assert_select ".soul-history__item", text: /Gained Cursed/
    assert_select ".soul-audit", count: 0
  end
end
