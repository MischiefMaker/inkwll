require "test_helper"

class FounderSetupTest < ActionDispatch::IntegrationTest
  setup { ENV["WELL_SETUP_CODE"] = "abc123abc123abc123" }
  teardown { ENV["WELL_SETUP_CODE"] = nil }

  def sign_up(name, setup)
    post registration_path, params: { setup: setup, account: { display_name: name, email: "#{name.downcase}@example.com", password: "Password123", password_confirmation: "Password123" } }
  end

  test "a new Well's setup link makes the first player its Founder, once" do
    Account.where(founder: true).update_all(founder: false)
    get new_registration_path(setup: "abc123abc123abc123")
    assert_select ".registration__founder"

    sign_up("Firstone", "abc123abc123abc123")
    first = Account.find_by!(display_name: "Firstone")
    assert first.founder?
    assert first.wellkeeper?

    delete session_path rescue nil
    sign_up("Secondone", "abc123abc123abc123")
    assert_not Account.find_by!(display_name: "Secondone").founder?
  end

  test "the setup link can open with the Founder's name and email filled in, but only with the code" do
    Account.where(founder: true).update_all(founder: false)
    get new_registration_path(setup: "abc123abc123abc123", name: "Beaker", email: "b@example.com")
    assert_select "input[name='account[display_name]'][value='Beaker']"
    assert_select "input[name='account[email]'][value='b@example.com']"

    get new_registration_path(setup: "wrong", name: "Beaker", email: "b@example.com")
    assert_select "input[name='account[display_name]'][value='Beaker']", count: 0
  end

  test "a wrong code makes an ordinary player" do
    Account.where(founder: true).update_all(founder: false)
    sign_up("Guesser", "wrongwrongwrong")
    assert_not Account.find_by!(display_name: "Guesser").founder?
  end

  test "the setup code reaches the game's container" do
    assert_includes YAML.load(ERB.new(Rails.root.join("config/deploy.yml").read).result)["env"]["secret"], "WELL_SETUP_CODE"
  end

  test "a Well shows the name it was started with until staff set one" do
    ENV["INKWLL_GAME_NAME"] = "Last Call of the Wild"
    GameSetting.current.update!(game_name: nil)
    get root_path
    assert_select ".site-header__name", text: "Last Call of the Wild"

    GameSetting.current.update!(game_name: "Renamed")
    get root_path
    assert_select ".site-header__name", text: "Renamed"
  ensure
    ENV["INKWLL_GAME_NAME"] = nil
  end
end
