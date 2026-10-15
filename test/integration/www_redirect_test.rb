require "test_helper"

class WwwRedirectTest < ActionDispatch::IntegrationTest
  setup { @app_host, ENV["APP_HOST"] = ENV["APP_HOST"], "example.com" }
  teardown { ENV["APP_HOST"] = @app_host }

  test "www. visits are sent on to the game's domain, keeping the page" do
    host! "www.example.com"
    get "/getting-started?tab=staff"

    assert_response :moved_permanently
    assert_redirected_to "http://example.com/getting-started?tab=staff"
  end

  test "visits to the game's domain are not redirected" do
    host! "example.com"
    get "/getting-started"

    assert_response :success
  end

  test "nothing is redirected when the game has no domain set" do
    ENV["APP_HOST"] = nil
    host! "www.example.com"
    get "/getting-started"

    assert_response :success
  end
end
