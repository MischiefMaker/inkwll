require "test_helper"

class StorytellerWantedTest < ActionDispatch::IntegrationTest
  test "a player asks for a Storyteller; Storytellers see it, and taking the role takes it off the list" do
    accounts(:bob).update!(storyteller: true)
    sign_in_as(accounts(:alice))
    post scene_storyteller_wanted_path(scenes(:duel))
    assert scenes(:duel).reload.storyteller_wanted?

    sign_in_as(accounts(:bob))
    get storyteller_wanted_path
    assert_select ".storyteller-wanted__title", text: "Duel at Dawn"
    patch scene_participation_path(scenes(:duel))
    assert_not scenes(:duel).reload.storyteller_wanted?
  end

  test "players without the Storyteller flag can't see the list" do
    sign_in_as(accounts(:alice))
    get storyteller_wanted_path
    assert_response :not_found
  end

  test "only players in the Chapter can ask, and only for one anyone can join" do
    sign_in_as(accounts(:alice))
    post scene_storyteller_wanted_path(scenes(:tea))
    assert_not scenes(:tea).reload.storyteller_wanted?

    sign_in_as(accounts(:bob))
    post scene_storyteller_wanted_path(scenes(:secret))
    assert_not scenes(:secret).reload.storyteller_wanted?
  end
end

class RulingTest < ActionDispatch::IntegrationTest
  test "players ask for a ruling in a hidden Chapter; staff read it and post a ruling" do
    sign_in_as(accounts(:bob))
    post scene_ruling_request_path(scenes(:secret)), params: { note: "Can Sable pick that lock?" }
    assert scenes(:secret).reload.ruling_wanted?

    sign_in_as(accounts(:scribe))
    assert_equal 1, StaffWaiting.count(accounts(:scribe), :rulings)
    get admin_rulings_path
    assert_select ".admin-rulings__note", text: "Can Sable pick that lock?"
    get scene_path(scenes(:secret))
    assert_response :success

    patch admin_ruling_path(scenes(:secret)), params: { ruling: "Yes, with a Finesse roll." }
    assert_not scenes(:secret).reload.ruling_wanted?
    assert_match "Yes, with a Finesse roll.", scenes(:secret).poses.last.body
  end

  test "a ruling needs a note, and can be taken back" do
    sign_in_as(accounts(:alice))
    post scene_ruling_request_path(scenes(:duel)), params: { note: " " }
    assert_not scenes(:duel).reload.ruling_wanted?
    post scene_ruling_request_path(scenes(:duel)), params: { note: "Who wins the duel?" }
    assert scenes(:duel).reload.ruling_wanted?
    delete scene_ruling_request_path(scenes(:duel))
    assert_not scenes(:duel).reload.ruling_wanted?
  end

  test "players can't give rulings or ask in Chapters they aren't in" do
    scenes(:duel).ask_for_ruling!(by: characters(:wren), note: "Who wins?")
    sign_in_as(accounts(:builder))
    patch admin_ruling_path(scenes(:duel)), params: { ruling: "Me!" }
    assert scenes(:duel).reload.ruling_wanted?

    post scene_ruling_request_path(scenes(:tea)), params: { note: "Hi" }
    assert_not scenes(:tea).reload.ruling_wanted?
  end
end
