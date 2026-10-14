require "test_helper"

class PlayerProfilesTest < ActionDispatch::IntegrationTest
  test "a player's characters are hidden from other players unless the game shows them" do
    GameSetting.current.update!(players_public: false)
    sign_in_as(accounts(:bob))
    get player_path(accounts(:alice).username)
    assert_response :success
    assert_select ".player-characters", count: 0

    GameSetting.current.update!(players_public: true)
    get player_path(accounts(:alice).username)
    assert_select ".player-characters__name", text: characters(:wren).name
  end

  test "players and staff always see the player's characters" do
    GameSetting.current.update!(players_public: false)
    sign_in_as(accounts(:alice))
    get player_path(accounts(:alice).username)
    assert_select ".player-characters__name", text: characters(:wren).name

    sign_in_as(accounts(:scribe))
    get player_path(accounts(:alice).username)
    assert_select ".player-characters__name", text: characters(:wren).name
  end

  test "a player edits only their own about me" do
    sign_in_as(accounts(:bob))
    patch player_profile_path, params: { account: { about_me: "I like tea.<script>alert(1)</script>" } }
    assert_redirected_to player_path(accounts(:bob).username)
    assert_equal "I like tea.<script>alert(1)</script>", accounts(:bob).reload.about_me

    get player_path(accounts(:bob).username)
    assert_select ".player-profile__about script", count: 0
    assert_select ".player-profile__about", text: /I like tea\./
  end

  test "a player icon must be a picture" do
    sign_in_as(accounts(:bob))
    text = Rack::Test::UploadedFile.new(StringIO.new("not a picture"), "text/plain", original_filename: "notes.txt")
    patch player_profile_path, params: { account: { icon: text } }
    assert_response :unprocessable_entity
    assert_not accounts(:bob).reload.icon.attached?

    patch player_profile_path, params: { account: { icon: fixture_file_upload("pixel.png", "image/png") } }
    assert accounts(:bob).reload.icon.attached?
  end

  test "guests can't see player profiles" do
    get player_path(accounts(:alice).username)
    assert_redirected_to new_session_path
  end
end
