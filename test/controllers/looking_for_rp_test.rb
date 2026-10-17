require "test_helper"

class LookingForRpTest < ActionDispatch::IntegrationTest
  test "a player switches it on with tags; the character shows on the list, in Here and on Where" do
    sign_in_as(accounts(:alice))
    post character_looking_for_rp_path(characters(:wren)), params: { i_am: "new in town", looking_for: "a tavern scene" }
    wren = characters(:wren).reload
    assert wren.looking_for_rp?
    assert_equal "a tavern scene", wren.lfrp_looking_for

    get looking_for_rp_path
    assert_select ".looking-for-rp__name", text: "Wren"
    assert_select ".looking-for-rp__looking-for", text: "Looking for a tavern scene"
    get room_path(wren.room)
    assert_select ".room-here .looking-for-rp-mark"
    get where_path
    assert_select ".where-room .looking-for-rp-mark"
  end

  test "switching it off is one click" do
    characters(:wren).look_for_rp!
    sign_in_as(accounts(:alice))
    delete character_looking_for_rp_path(characters(:wren))
    assert_not characters(:wren).reload.looking_for_rp?
  end

  test "players who haven't been around for a week drop off the list" do
    characters(:wren).look_for_rp!(looking_for: "anything")
    accounts(:alice).update_columns(last_seen_at: 8.days.ago)
    get looking_for_rp_path
    assert_select ".looking-for-rp__name", count: 0
  end

  test "guests can read the list" do
    characters(:wren).look_for_rp!
    accounts(:alice).update_columns(last_seen_at: Time.current)
    get looking_for_rp_path
    assert_response :success
    assert_select ".looking-for-rp__name", text: "Wren"
  end

  test "someone else's character can't be flagged" do
    sign_in_as(accounts(:bob))
    post character_looking_for_rp_path(characters(:wren))
    assert_response :not_found
    assert_not characters(:wren).reload.looking_for_rp?
  end

  test "a character waiting for approval can't look for RP" do
    GameSetting.current.update!(approval_required: true)
    characters(:wren).update_columns(status: "submitted")
    sign_in_as(accounts(:alice))
    post character_looking_for_rp_path(characters(:wren))
    assert_not characters(:wren).reload.looking_for_rp?
  end
end
