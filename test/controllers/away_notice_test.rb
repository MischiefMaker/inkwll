require "test_helper"

class AwayNoticeTest < ActionDispatch::IntegrationTest
  test "a player sets an away notice, and it shows beside their turn" do
    sign_in_as(accounts(:bob))
    patch player_profile_path, params: { account: { away_until: 3.days.from_now.to_date, away_note: "Visiting family" } }
    assert accounts(:bob).reload.away?

    scene = scenes(:duel)
    sable = scene.participants.find_by!(character: characters(:sable))
    scene.update_columns(current_turn_participant_id: sable.id)
    sign_in_as(accounts(:alice))
    get scene_path(scene)
    assert_select ".scene-people__away", text: /Away until .*Visiting family/
    assert_select ".turn-bar__away", text: /Visiting family/
  end

  test "the notice clears itself after its day" do
    accounts(:bob).update_columns(away_until: Date.yesterday)
    assert_not accounts(:bob).away?
    assert_nil accounts(:bob).away_label
  end

  test "it can't be set in the past" do
    sign_in_as(accounts(:bob))
    patch player_profile_path, params: { account: { away_until: Date.yesterday } }
    assert_nil accounts(:bob).reload.away_until
  end
end
