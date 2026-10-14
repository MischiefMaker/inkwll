require "test_helper"

class Admin::CharactersControllerTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper can delete a character" do
    sign_in_as(accounts(:wellkeeper))

    assert_difference "Character.count", -1 do
      delete admin_character_path(characters(:moth))
    end
  end

  test "a Scribe can't delete characters" do
    sign_in_as(accounts(:scribe))

    assert_no_difference "Character.count" do
      delete admin_character_path(characters(:moth))
    end
    assert_redirected_to root_path
  end
end
