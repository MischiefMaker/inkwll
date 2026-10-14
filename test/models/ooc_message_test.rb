require "test_helper"

class OocMessageTest < ActiveSupport::TestCase
  test "body is required" do
    assert_not accounts(:alice).ooc_messages.new(body: "").valid?
  end
end
