require "test_helper"

class SceneBountyTest < ActionDispatch::IntegrationTest
  setup do
    GameSetting.current.update!(soul_enabled: true)
    Character.update_all(last_active_at: 1.day.ago, created_at: 60.days.ago)
  end

  test "My Chapters shows the week's bounty, never your own characters, and it stays the same all week" do
    sign_in_as(accounts(:alice))
    get my_chapters_path
    assert_select ".scene-bounty__name", text: "Sable"
    assert_select ".scene-bounty__name", text: "Wren", count: 0
    first = SceneBounty.for(accounts(:alice)).character_ids
    get my_chapters_path
    assert_equal first, SceneBounty.for(accounts(:alice)).character_ids
  end

  test "new characters are always on the list" do
    Character.update_all(last_active_at: 60.days.ago)
    characters(:finch).update_columns(created_at: 2.days.ago)
    assert_includes SceneBounty.for(accounts(:alice)).character_ids, characters(:finch).id
  end

  test "finishing a Chapter with someone on your bounty earns extra XP, once a week" do
    bounty = SceneBounty.for(accounts(:alice))
    bounty.update!(character_ids: [ characters(:sable).id ])
    scene = scenes(:duel)
    assert_difference -> { characters(:wren).xp_entries.where(source: "bounty").sum(:amount) }, SceneBounty.award do
      scene.finish!(by: characters(:wren))
    end
    assert_equal 0, characters(:sable).xp_entries.where(source: "bounty").count

    scene.reopen!(by: characters(:wren))
    assert_no_difference -> { characters(:wren).xp_entries.where(source: "bounty").count } do
      scene.reload.finish!(by: characters(:wren))
    end
  end

  test "no bounty when SOUL is off" do
    GameSetting.current.update!(soul_enabled: false)
    sign_in_as(accounts(:alice))
    get my_chapters_path
    assert_select ".scene-bounty", count: 0
  end
end
