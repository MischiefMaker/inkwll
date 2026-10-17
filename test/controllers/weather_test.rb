require "test_helper"

class WeatherTest < ActionDispatch::IntegrationTest
  test "staff-written weather shows everywhere, outdoors and in" do
    GameSetting.current.update!(weather: "Rain over the hills")
    rooms(:garden).update!(kind: "outdoor")
    get room_path(rooms(:garden))
    assert_select ".weather--outdoor .weather__words", text: "Rain over the hills"
    get room_path(rooms(:hall))
    assert_select ".weather--indoor .weather__label", text: "Outside:"
    get root_path
    assert_select ".game-time__weather", text: "Rain over the hills"
  end

  test "without staff weather, automatic weather follows the season and holds steady" do
    settings = GameSetting.current
    settings.update!(weather: nil, weather_auto: true, ic_anchor_date: Date.new(1200, 1, 10), ic_anchor_at: Time.current)
    assert_equal "winter", Weather.season(settings)
    at = Time.current
    weather = Weather.now(settings, at: at)
    assert_includes Weather::SEASONS["winter"], weather
    assert_equal weather, Weather.now(settings, at: at)
    settings.update!(weather_southern: true)
    assert_equal "summer", Weather.season(settings)
    get room_path(rooms(:hall))
    assert_select ".weather__words"
  end

  test "no weather shows when there's none" do
    GameSetting.current.update!(weather: nil, weather_auto: false)
    get room_path(rooms(:hall))
    assert_select ".weather", count: 0
  end

  test "only staff who change game settings switch it on" do
    sign_in_as(accounts(:builder))
    patch admin_game_settings_path, params: { game_setting: { weather_auto: "1" } }
    assert_not GameSetting.current.reload.weather_auto?
  end
end
