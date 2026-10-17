require "test_helper"

class NpcsTest < ActionDispatch::IntegrationTest
  test "staff make an NPC; everyone sees its description, only staff and Storytellers its notes" do
    sign_in_as(accounts(:scribe))
    post admin_npcs_path, params: { npc: { name: "Old Marta", description: "Runs the ferry.", notes: "Smuggles at night.", soul_ratings: { soul_skills(:wit).id => "4" } } }
    marta = Npc.find_by!(name: "Old Marta")
    assert_equal({ soul_skills(:wit).id.to_s => 4 }, marta.soul_ratings)

    get npcs_path
    assert_select ".npcs__notes", text: /Smuggles at night/

    sign_out
    get npcs_path
    assert_select ".npcs__description", text: /Runs the ferry/
    assert_select ".npcs__notes", count: 0
    assert_select ".npcs__ratings", count: 0
  end

  test "players can't make NPCs" do
    sign_in_as(accounts(:alice))
    post admin_npcs_path, params: { npc: { name: "Sneaky" } }
    assert_not Npc.exists?(name: "Sneaky")
  end

  test "whoever runs the Chapter posts as one of the game's NPCs, and it takes their name" do
    marta = Npc.create!(name: "Old Marta")
    sign_in_as(accounts(:alice))
    post scene_poses_path(scenes(:duel)), params: { pose: { kind: "npc", npc_id: marta.id, body: "Ferry's leaving!" } }, headers: {}
    pose = scenes(:duel).poses.npc.last
    assert_equal marta, pose.npc
    assert_equal "Old Marta", pose.npc_name
  end

  test "with a Storyteller in the Chapter, only they can bring in the game's NPCs" do
    accounts(:bob).update!(storyteller: true)
    scenes(:duel).participant_for(characters(:sable)).update!(role: "storyteller")
    marta = Npc.create!(name: "Old Marta")
    sign_in_as(accounts(:alice))
    post scene_poses_path(scenes(:duel)), params: { pose: { kind: "npc", npc_id: marta.id, body: "Ferry's leaving!" }, post_anyway: "1" }
    assert_nil scenes(:duel).poses.npc.last&.npc
  end
end
