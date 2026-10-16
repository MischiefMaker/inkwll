require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "pages send a policy that only allows the game's own scripts" do
    get root_path
    policy = response.headers["Content-Security-Policy"]
    assert_match(/script-src 'self' 'nonce-/, policy)
    assert_no_match(/script-src[^;]*unsafe/, policy)
    assert_match(/object-src 'none'/, policy)
    assert_match(/frame-ancestors 'none'/, policy)
  end

  test "the page's own script tags carry the nonce" do
    get root_path
    nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
    assert_select "script[type=importmap][nonce=?]", nonce
    assert_select "script[type=module][nonce=?]", nonce
  end
end
