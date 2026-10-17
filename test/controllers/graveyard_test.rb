require "test_helper"

class GraveyardTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper marks a character deceased; they're retired and in the Graveyard" do
    sign_in_as(accounts(:wellkeeper))
    post decease_admin_character_path(characters(:sable)), params: { deceased_note: "Lost at sea." }
    sable = characters(:sable).reload
    assert sable.deceased?
    assert sable.retired?
    assert_equal IcClock.today, sable.deceased_on

    sign_out
    get graveyard_path
    assert_select ".graveyard__name", text: "Sable"
    assert_select ".graveyard__epitaph", text: "Lost at sea."
    get character_path(sable)
    assert_select ".character-profile__deceased", text: /Lost at sea/
  end

  test "bringing a character back takes them out of the Graveyard" do
    characters(:sable).die!(note: "Gone")
    sign_in_as(accounts(:wellkeeper))
    post unretire_admin_character_path(characters(:sable))
    assert_not characters(:sable).reload.deceased?
    assert_not characters(:sable).retired?
  end

  test "several at once from the tick boxes" do
    sign_in_as(accounts(:wellkeeper))
    post admin_character_batch_path, params: { decision: "deceased", character_ids: [ characters(:wren).id, characters(:moth).id ] }
    assert characters(:wren).reload.deceased?
    assert characters(:moth).reload.deceased?
  end

  test "players can't mark characters deceased" do
    sign_in_as(accounts(:bob))
    post decease_admin_character_path(characters(:sable))
    assert_not characters(:sable).reload.deceased?
  end
end
