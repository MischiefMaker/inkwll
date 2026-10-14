require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "logged out visitors are sent to log in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "shows the game's name and blurb" do
    GameSetting.current.update!(game_name: "Moonfall", game_blurb: "A city under two moons.")
    sign_in_as(accounts(:alice))
    get root_path

    assert_select ".game-intro__name", "Moonfall"
    assert_select ".game-intro__blurb", text: "A city under two moons."
    assert_select ".site-header__title", "Moonfall"
    assert_select "title", "Moonfall"
  end

  test "lists only top-level areas, each with a way in" do
    sign_in_as(accounts(:alice))
    get root_path

    assert_response :success
    assert_select ".place__title", "The World"
    assert_select ".place__title", text: "Castle", count: 0
    assert_select ".where-now a", "The Commons"
  end

  test "Enter takes the character to the area's entrance" do
    area = Area.create!(name: "Elsewhere")
    room = Room.create!(name: "Gate", area: area)
    sign_in_as(accounts(:alice))
    get root_path
    assert_select "##{ActionView::RecordIdentifier.dom_id(area, :place)} form[action=?]", room_travel_path(room)

    post room_travel_path(room)
    assert_equal room, characters(:wren).reload.room
  end

  test "Enter goes to the first Setting made unless another is ticked as the default" do
    area = Area.create!(name: "Elsewhere")
    first = Room.create!(name: "Zed Gate", area: area)
    second = Room.create!(name: "Arch", area: area)
    assert_equal first, area.entrance

    sign_in_as(accounts(:builder))
    patch admin_room_path(second), params: { room: { area_default: "1" } }
    assert_equal second, area.reload.entrance

    patch admin_room_path(second), params: { room: { area_default: "0" } }
    assert_equal first, area.reload.entrance
  end

  test "an Area with no Settings can only be looked at" do
    area = Area.create!(name: "Empty Moor")
    sign_in_as(accounts(:alice))
    get root_path
    assert_select "##{ActionView::RecordIdentifier.dom_id(area, :place)} a.place__look[href=?]", area_path(area)
  end

  test "players without a character see Enter too, and are asked to make one" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select ".place__enter-form", minimum: 1
    post room_travel_path(rooms(:commons))
    assert_redirected_to new_character_path
  end

  test "shortcuts to every setting are tucked into a fold" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".place__shortcuts .place__shortcuts-list a", text: "Garden"
  end

  test "players without characters are asked to make one" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select ".where-now a[href=?]", new_character_path
  end

  test "areas show their latest open Chapter, never a private or hidden one" do
    party = Scene.create!(room: rooms(:garden), title: "Garden Party")
    party.participants.create!(character: characters(:wren), position: 1)
    party.post!(characters(:wren), "Wren pours the tea.")
    secret = Scene.create!(room: rooms(:garden), title: "Behind the Hedge", visibility: "hidden")
    secret.participants.create!(character: characters(:sable), position: 1)
    secret.post!(characters(:sable), "Psst.")

    sign_in_as(accounts(:alice))
    get root_path

    assert_select ".place__latest a", text: "Garden Party"
    assert_select ".place__latest a", text: "Behind the Hedge", count: 0
  end
end
