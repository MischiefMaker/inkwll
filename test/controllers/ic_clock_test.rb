require "test_helper"

class IcClockTest < ActionDispatch::IntegrationTest
  setup do
    GameSetting.current.update!(ic_today: "1526-10-14")
    accounts(:alice).update!(active_character: characters(:wren))
  end

  test "a new Chapter starts on the game's date, or the date its player picks" do
    sign_in_as(accounts(:alice))
    post scenes_path, params: { scene: { title: "Harvest", visibility: "joinable", pose_mode: "free" } }
    assert_equal "1526-10-14", Scene.last.ic_date.iso8601

    post scenes_path, params: { scene: { title: "Before", visibility: "joinable", pose_mode: "free", ic_date: "1526-09-01", ic_time: "Dawn" } }
    assert_equal "September 01, 1526, Dawn", Scene.last.ic_when
  end

  test "a player in the Chapter moves its date, and the Chapter says so" do
    scene = scenes(:duel)
    scene.update_column(:ic_date, Date.new(1526, 10, 14, Date::GREGORIAN))
    sign_in_as(accounts(:alice))

    assert_difference "scene.poses.count" do
      patch scene_path(scene), params: { scene: { title: scene.title, ic_date: "1526-10-15", ic_time: "Morning" } }
    end
    assert_equal "1526-10-15", scene.reload.ic_date.iso8601
    assert_match "Wren moved the chapter to October 15, 1526, Morning.", scene.poses.last.body

    assert_no_difference "scene.poses.count" do
      patch scene_path(scene), params: { scene: { title: scene.title, ic_date: "1526-10-15", ic_time: "Morning" } }
    end
  end

  test "someone outside the Chapter can't move its date" do
    scenes(:tea).update_column(:ic_date, Date.new(1526, 10, 14, Date::GREGORIAN))
    sign_in_as(accounts(:bob))
    patch scene_path(scenes(:tea)), params: { scene: { ic_date: "1600-01-01" } }
    assert_equal "1526-10-14", scenes(:tea).reload.ic_date.iso8601
  end

  test "the front page shows the game date, the weather and who's online" do
    GameSetting.current.update!(weather: "Rain over the hills")
    accounts(:bob).update!(active_character: characters(:sable), last_seen_at: Time.current)
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".game-time__date", text: "It is October 14, 1526."
    assert_select ".game-time__weather", text: "Rain over the hills"
    assert_select ".online-now__title", text: /Online now \(1\)/
    assert_select ".online-now__player .online-now__name", text: "Bob"
    assert_select ".online-now__player .player-icon"
    assert_select ".online-now__where[href=?]", where_path
    # Who they're playing stays hidden from other players unless the game shows players.
    assert_select ".online-now__playing", count: 0
  end

  test "only staff who change game settings set the weather" do
    sign_in_as(accounts(:scribe))
    patch admin_game_settings_path, params: { game_setting: { weather: "Snow" } }
    assert_nil GameSetting.current.reload.weather
  end
end
