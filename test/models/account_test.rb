require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "usernames are stored in lowercase so login is not case-sensitive" do
    account = Account.create!(username: " NewPlayer ", display_name: "New", password: "secret123")
    assert_equal "newplayer", account.username
  end

  test "usernames must be unique" do
    account = Account.new(username: "ALICE", display_name: "Other", password: "secret123")
    assert_not account.valid?
  end

  test "switching character makes it active and remembers it for its room" do
    alice = accounts(:alice)
    alice.switch_to(characters(:moth))

    assert_equal characters(:moth), alice.reload.active_character
    assert_equal characters(:moth), alice.remembered_character_for(rooms(:hall))
  end

  test "cannot make another player's character active" do
    alice = accounts(:alice)
    alice.active_character = characters(:sable)
    assert_not alice.valid?
  end

  test "remembering a character for the same place replaces the old memory" do
    alice = accounts(:alice)
    alice.remember_character(characters(:wren), rooms(:commons))
    alice.remember_character(characters(:moth), rooms(:commons))

    assert_equal characters(:moth), alice.remembered_character_for(rooms(:commons))
    assert_equal 1, alice.remembered_characters.where(context: rooms(:commons)).count
  end
end
