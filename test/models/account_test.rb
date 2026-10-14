require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "the player name is also the login name, ignoring capitals" do
    account = Account.create!(display_name: " NewPlayer ", email: "new@example.com", password: "secret123")
    assert_equal "NewPlayer", account.display_name
    assert_equal "newplayer", account.username
    assert_equal account, Account.log_in("NEWPLAYER", "secret123")
  end

  test "player names must be unique, ignoring capitals" do
    account = Account.new(display_name: "ALICE", email: "other@example.com", password: "secret123")
    assert_not account.valid?
    assert_includes account.errors[:display_name], "is already taken"
  end

  test "player names can't have spaces" do
    account = Account.new(display_name: "Two Words", email: "two@example.com", password: "secret123")
    assert_not account.valid?
  end

  test "email is required unless the game makes it optional" do
    account = Account.new(display_name: "NoEmail", password: "secret123")
    assert_not account.valid?

    GameSetting.current.update!(email_required: false)
    assert account.valid?
  end

  test "emails must be unique and look like emails" do
    assert_not Account.new(display_name: "Copy", email: "ALICE@example.com", password: "secret123").valid?
    assert_not Account.new(display_name: "Typo", email: "not-an-email", password: "secret123").valid?
  end

  test "Pages can only do the jobs they've been given" do
    builder = accounts(:builder)
    assert builder.can?(:build)
    assert_not builder.can?(:review_apps)
    assert_not builder.can?(:manage_staff)
    assert_not accounts(:alice).can?(:build)
  end

  test "Scribes can do everything except fundamental changes" do
    scribe = accounts(:scribe)
    assert scribe.can?(:build)
    assert scribe.can?(:manage_staff)
    assert_not scribe.can?(:delete_characters)
    assert_not scribe.can?(:change_game_settings)
    assert accounts(:wellkeeper).can?(:delete_characters)
  end

  test "staff can only manage people below them, and only Founders make Wellkeepers" do
    assert accounts(:scribe).can_manage?(accounts(:builder))
    assert_not accounts(:scribe).can_manage?(accounts(:wellkeeper))
    assert_not accounts(:wellkeeper).can_manage?(accounts(:wellkeeper))
    assert_not accounts(:wellkeeper).assignable_staff_levels.include?(:wellkeeper)

    founder = accounts(:founder)
    assert founder.can_manage?(accounts(:wellkeeper))
    assert_includes founder.assignable_staff_levels, :wellkeeper
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
