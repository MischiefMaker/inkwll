require "test_helper"

class WhereControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "shows where characters stand and the open Chapters they're in" do
    get where_path

    assert_select ".where-room h2", text: "The Commons"
    assert_select "li", text: /Wren\s+in\s+Duel at Dawn/
  end

  test "never shows private or hidden Chapters" do
    get where_path
    assert_select "a", text: "A Quiet Word", count: 0
    assert_select "a", text: "Afternoon Tea", count: 0
  end
end
