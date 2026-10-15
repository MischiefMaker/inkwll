require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials, ignoring capitals in the player name" do
    post session_path, params: { username: "Alice", password: "password" }

    assert_redirected_to root_path
    assert cookies["inkwll_login"]
  end

  test "the login cookie lasts until the browser closes over plain http" do
    post session_path, params: { username: "alice", password: "password" }

    login_cookie = Array(response.headers["Set-Cookie"]).flat_map(&:lines).find { |line| line.start_with?("inkwll_login=") }
    assert_no_match(/expires=/i, login_cookie)
  end

  test "the login cookie is long-lived over https" do
    https!
    post session_path, params: { username: "alice", password: "password" }

    login_cookie = Array(response.headers["Set-Cookie"]).flat_map(&:lines).find { |line| line.start_with?("inkwll_login=") }
    assert_match(/expires=/i, login_cookie)
  end

  test "create with invalid credentials" do
    post session_path, params: { username: "alice", password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies["inkwll_login"]
  end

  test "destroy" do
    sign_in_as(accounts(:alice))

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies["inkwll_login"]
  end
end
