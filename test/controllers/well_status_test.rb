require "test_helper"

class WellStatusTest < ActionDispatch::IntegrationTest
  test "it says only whether the Well has a Founder, to anyone" do
    get well_status_path
    assert_response :success
    assert_equal({ "founder" => true }, response.parsed_body)

    Account.where(founder: true).update_all(founder: false)
    get well_status_path
    assert_equal({ "founder" => false }, response.parsed_body)
  end
end
