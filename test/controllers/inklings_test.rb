require "test_helper"

class InklingsTest < ActionDispatch::IntegrationTest
  def start(kind: "goal", title: "Learn to sail", body: "Wren wants a boat.")
    sign_in_as(accounts(:alice))
    post inklings_path, params: { inkling: { character_id: characters(:wren).id, kind: kind, title: title, body: body } }
    Inkling.last
  end

  test "a player starts an Inkling, and staff can't see it until it's sent" do
    inkling = start
    assert_redirected_to inkling_path(inkling)
    assert inkling.draft?
    assert_equal 1, inkling.entries.count

    sign_in_as(accounts(:scribe))
    get inkling_path(inkling)
    assert_response :not_found
    get admin_inklings_path
    assert_select "a", text: "Learn to sail", count: 0
  end

  test "sending it to staff locks it until staff decide, and a reply doesn't unlock it" do
    inkling = start
    post inkling_submission_path(inkling)
    assert inkling.reload.submitted?

    post inkling_entries_path(inkling), params: { body: "One more thing!", kind: "public" }
    assert_equal 2, inkling.entries.where(kind: "public").count + inkling.entries.where(kind: "system").count

    sign_in_as(accounts(:scribe))
    get admin_inklings_path
    assert_select ".inklings-admin--waiting a", text: "Learn to sail"
    post inkling_entries_path(inkling), params: { body: "Tell me more about the boat.", kind: "public" }
    assert inkling.reload.submitted?

    post inkling_review_path(inkling), params: { decision: "approve" }
    assert inkling.reload.approved?
    assert accounts(:alice).alerts.exists?(kind: "inkling", inkling: inkling)

    sign_in_as(accounts(:alice))
    post inkling_entries_path(inkling), params: { body: "Wren buys the boat.", kind: "public" }
    assert inkling.entries.exists?(body: "Wren buys the boat.")
  end

  test "staff can send it back for changes" do
    inkling = start
    post inkling_submission_path(inkling)
    sign_in_as(accounts(:scribe))
    post inkling_review_path(inkling), params: { decision: "changes", note: "Which harbour?" }
    assert inkling.reload.needs_changes?
    assert inkling.entries.exists?(body: "Which harbour?")
  end

  test "players can't review Inklings" do
    inkling = start
    post inkling_submission_path(inkling)
    post inkling_review_path(inkling), params: { decision: "approve" }
    assert inkling.reload.submitted?
  end

  test "private, personal and staff notes are only seen by the right people" do
    inkling = start
    post inkling_entries_path(inkling), params: { body: "Wren is secretly afraid of water.", kind: "private" }
    post inkling_entries_path(inkling), params: { body: "Remember to ask about boats.", kind: "personal" }
    post inkling_entries_path(inkling), params: { body: "Trying to sneak a staff note.", kind: "gm" }
    assert_not inkling.entries.exists?(kind: "gm")
    post inkling_shares_path(inkling), params: { name: "Sable" }
    post inkling_submission_path(inkling)

    sign_in_as(accounts(:scribe))
    post inkling_entries_path(inkling), params: { body: "Plan a storm for this.", kind: "gm" }
    get inkling_path(inkling)
    assert_select ".inkling-entry__body", text: /secretly afraid/
    assert_select ".inkling-entry__body", text: /Remember to ask/, count: 0

    sign_in_as(accounts(:bob))
    get inkling_path(inkling)
    assert_response :success
    assert_select ".inkling-entry__body", text: /Wren wants a boat/
    assert_select ".inkling-entry__body", text: /secretly afraid/, count: 0
    assert_select ".inkling-entry__body", text: /Plan a storm/, count: 0

    sign_in_as(accounts(:alice))
    get inkling_path(inkling)
    assert_select ".inkling-entry__body", text: /Remember to ask/
    assert_select ".inkling-entry__body", text: /Plan a storm/, count: 0
  end

  test "characters it's shared with can read it and write in it; others can't" do
    inkling = start
    sign_in_as(accounts(:bob))
    get inkling_path(inkling)
    assert_response :not_found

    sign_in_as(accounts(:alice))
    post inkling_shares_path(inkling), params: { name: "sable" }
    sign_in_as(accounts(:bob))
    get inklings_path
    assert_select ".inklings__title", text: "Learn to sail"
    post inkling_entries_path(inkling), params: { body: "Sable offers a rowing boat.", kind: "public" }
    assert_equal characters(:sable), inkling.entries.last.character
    assert accounts(:alice).alerts.exists?(kind: "inkling", inkling: inkling)

    post inkling_shares_path(inkling), params: { name: "Lark" }
    assert_not inkling.shares.exists?(character: characters(:lark))
  end

  test "sharing with a character group" do
    ravens = CharacterGroup.create!(name: "Ravens", colour: "#336699")
    characters(:sable).update!(character_group: ravens)
    inkling = start
    post inkling_shares_path(inkling), params: { group_id: ravens.id }
    sign_in_as(accounts(:bob))
    get inkling_path(inkling)
    assert_response :success
  end

  test "players can't start staff types, but staff start them for a character" do
    sign_in_as(accounts(:alice))
    assert_no_difference "Inkling.count" do
      post inklings_path, params: { inkling: { character_id: characters(:wren).id, kind: "hint", title: "Psst", body: "x" } }
    end

    sign_in_as(accounts(:scribe))
    post inklings_path, params: { inkling: { character_id: characters(:wren).id, kind: "hint", title: "A strange map", body: "You find a map." } }
    inkling = Inkling.last
    assert_equal characters(:wren), inkling.character
    assert inkling.staff_visible_at

    sign_in_as(accounts(:alice))
    get inkling_path(inkling)
    assert_select ".inkling-entry__author", text: /Staff/
  end

  test "players can't start an Inkling for someone else's character" do
    sign_in_as(accounts(:bob))
    post inklings_path, params: { inkling: { character_id: characters(:wren).id, kind: "goal", title: "Mine now", body: "x" } }
    assert_response :not_found
  end

  test "staff reward XP, and players can't" do
    inkling = start
    post inkling_submission_path(inkling)
    post inkling_rewards_path(inkling), params: { reward_type: "xp", amount: 5 }
    assert_equal 0, characters(:wren).xp_entries.count

    sign_in_as(accounts(:scribe))
    post inkling_rewards_path(inkling), params: { reward_type: "xp", amount: 5 }
    assert_equal 5, characters(:wren).xp_entries.sum(:amount)
    assert inkling.entries.exists?(kind: "reward")
  end

  test "rolling a Skill in an Inkling" do
    inkling = start
    post inkling_rolls_path(inkling), params: { skill_id: soul_skills(:wit).id, difficulty: "standard", private: "1" }
    entry = inkling.entries.last
    assert_equal "roll", entry.kind
    assert entry.private?
    assert entry.soul_roll
  end

  test "closing, and only staff reopen" do
    inkling = start
    post inkling_closing_path(inkling)
    assert inkling.reload.closed?
    delete inkling_closing_path(inkling)
    assert inkling.reload.closed?
    post inkling_entries_path(inkling), params: { body: "Too late.", kind: "public" }
    assert_not inkling.entries.exists?(body: "Too late.")
  end

  test "Inklings can be switched off" do
    GameSetting.current.update!(inklings_enabled: false)
    sign_in_as(accounts(:alice))
    get inklings_path
    assert_response :not_found
  end
end
