require "test_helper"

class CensusTest < ActionDispatch::IntegrationTest
  setup do
    Character.update_all(last_active_at: 1.day.ago, status: "approved")
    @guard = CharacterGroup.create!(name: "Night Watch", colour: "#336699")
    @court = CharacterGroup.create!(name: "Court", colour: "#993366", needs_players: true, wanted_note: "A herald")
    characters(:wren).update!(character_group: @guard)
    characters(:sable).update!(character_group: @guard)
  end

  test "the directory counts characters played lately per group, with staff's wanted note" do
    characters(:moth).update_columns(last_active_at: 60.days.ago)
    get directory_path
    assert_select ".census__item", text: /Night Watch\s*2/
    assert_select ".census__item--wanted", text: /Court\s*0\s*Needs players\s*A herald/
  end

  test "Wellkeepers mark a group as needing players" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_character_group_path(@guard), params: { character_group: { needs_players: "1", wanted_note: "Two more guards" } }
    assert @guard.reload.needs_players?
    assert_equal "Two more guards", @guard.wanted_note
  end

  test "players can't change it" do
    sign_in_as(accounts(:alice))
    patch admin_character_group_path(@guard), params: { character_group: { needs_players: "1" } }
    assert_not @guard.reload.needs_players?
  end
end
