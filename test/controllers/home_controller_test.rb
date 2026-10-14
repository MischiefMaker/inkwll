require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "logged out visitors are sent to log in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "shows top-level areas as banners with the areas inside as boards" do
    sign_in_as(accounts(:alice))
    get root_path

    assert_response :success
    assert_select ".category__title", "The World"
    assert_select ".board-row__title > a", text: "Castle"
    assert_select ".where-now a", "The Commons"
  end

  test "the arrow beside an area lists shortcuts to its settings" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".shortcuts a", text: "Garden"
  end

  test "players without characters are asked to make one" do
    sign_in_as(accounts(:scribe))
    get root_path
    assert_select ".where-now a[href=?]", new_character_path
  end

  test "boards show their latest open Chapter, never a private or hidden one" do
    party = Scene.create!(room: rooms(:garden), title: "Garden Party")
    party.participants.create!(character: characters(:wren), position: 1)
    party.post!(characters(:wren), "Wren pours the tea.")
    secret = Scene.create!(room: rooms(:garden), title: "Behind the Hedge", visibility: "hidden")
    secret.participants.create!(character: characters(:sable), position: 1)
    secret.post!(characters(:sable), "Psst.")

    sign_in_as(accounts(:alice))
    get root_path

    assert_select ".board-row__latest", text: "Garden Party"
    assert_select ".board-row__latest", text: "Behind the Hedge", count: 0
  end

  test "Settings directly in a top-level Area show their latest open Chapter under its banner" do
    sign_in_as(accounts(:alice))
    get root_path
    assert_select ".category__latest a", text: "Duel at Dawn"
  end
end
