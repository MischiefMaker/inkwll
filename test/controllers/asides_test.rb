require "test_helper"

class AsidesTest < ActionDispatch::IntegrationTest
  setup do
    accounts(:bob).update!(storyteller: true)
    scenes(:duel).participant_for(characters(:sable)).update!(role: "storyteller")
  end

  test "the Storyteller sends an aside; only that character's player sees it, and gets an alert" do
    sign_in_as(accounts(:bob))
    post scene_asides_path(scenes(:duel)), params: { to: characters(:wren).id, body: "You notice the blade is chipped." }
    pose = scenes(:duel).poses.aside.last
    assert_equal [ characters(:wren).id ], pose.to_character_ids
    assert Alert.exists?(account: accounts(:alice), kind: "aside")

    sign_in_as(accounts(:alice))
    get scene_path(scenes(:duel))
    assert_select ".pose--aside .pose__body", text: /blade is chipped/

    sign_in_as(accounts(:builder))
    get scene_path(scenes(:duel))
    assert_select ".pose--aside", count: 0
    assert_no_match "blade is chipped", response.body
  end

  test "only the Storyteller can send one" do
    sign_in_as(accounts(:alice))
    post scene_asides_path(scenes(:duel)), params: { to: characters(:sable).id, body: "Psst" }
    assert_equal 0, scenes(:duel).poses.aside.count
  end
end
