require "test_helper"

class Scenes::TurnsControllerTest < ActionDispatch::IntegrationTest
  test "passing your turn" do
    sign_in_as(accounts(:alice))
    post pass_scene_turn_path(scenes(:duel))
    assert scenes(:duel).reload.turn_of?(scene_participants(:duel_sable))
  end

  test "a storyteller skipping someone" do
    accounts(:bob).update!(storyteller: true)
    scene_participants(:duel_sable).update!(role: "storyteller")
    sign_in_as(accounts(:bob))

    get scene_path(scenes(:duel))
    assert_select "button", text: "Skip Wren"
    post skip_scene_turn_path(scenes(:duel))
    assert scenes(:duel).reload.turn_of?(scene_participants(:duel_sable))
  end

  test "I'm here! appears after the warning" do
    scenes(:duel).update!(turn_warned_at: Time.current)
    sign_in_as(accounts(:alice))

    get scene_path(scenes(:duel))
    assert_select "button", text: "I'm here!"
    post here_scene_turn_path(scenes(:duel))
    assert_nil scenes(:duel).reload.turn_warned_at
  end
end
