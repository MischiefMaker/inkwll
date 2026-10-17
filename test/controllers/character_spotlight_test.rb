require "test_helper"

class CharacterSpotlightTest < ActionDispatch::IntegrationTest
  setup do
    Character.update_all(last_active_at: 60.days.ago)
    characters(:wren).update_columns(last_active_at: 1.day.ago)
  end

  test "the front page shows a character played lately, with a public line from their profile" do
    characters(:wren).profile_values.create!(profile_field: profile_fields(:hometown), value: "Saltmarsh, by the sea")
    get root_path
    assert_select ".character-spotlight__name", text: "Wren"
    assert_select ".character-spotlight__line", text: "Saltmarsh, by the sea"
  end

  test "private answers never show" do
    characters(:wren).profile_values.create!(profile_field: profile_fields(:background), value: "A secret past")
    get root_path
    assert_select ".character-spotlight__line", count: 0
  end

  test "nobody played lately, or switched off, means no spotlight" do
    GameSetting.current.update!(character_spotlight: false)
    get root_path
    assert_select ".character-spotlight", count: 0

    GameSetting.current.update!(character_spotlight: true)
    characters(:wren).update_columns(last_active_at: 60.days.ago)
    get root_path
    assert_select ".character-spotlight", count: 0
  end

  test "the same character all day" do
    characters(:sable).update_columns(last_active_at: 1.day.ago)
    day = Date.new(2026, 10, 17)
    assert_equal CharacterSpotlight.today(day), CharacterSpotlight.today(day)
  end
end
