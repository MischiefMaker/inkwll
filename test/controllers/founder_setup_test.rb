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

  test "a wrong code makes an ordinary player" do
    Account.where(founder: true).update_all(founder: false)
    sign_up("Guesser", "wrongwrongwrong")
    assert_not Account.find_by!(display_name: "Guesser").founder?
  end
end
