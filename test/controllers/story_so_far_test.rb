require "test_helper"

class StorySoFarTest < ActionDispatch::IntegrationTest
  test "a player in the Chapter writes the story so far; it shows at the top and as one line in the list" do
    sign_in_as(accounts(:alice))
    patch scene_summary_path(scenes(:duel)), params: { summary: "Wren challenged Sable at dawn. Swords are drawn." }
    scene = scenes(:duel).reload
    assert_equal characters(:wren), scene.summary_by

    get scene_path(scene)
    assert_select ".scene-summary__text", text: /Swords are drawn/
    get room_path(scene.room)
    assert_select ".scene-list__summary", text: /Wren challenged Sable/
  end

  test "the Bookshelf shows the line once it's finished" do
    scenes(:duel).update_summary!("A duel at dawn.", by: characters(:wren))
    scenes(:duel).finish!(by: characters(:wren))
    get archives_path
    assert_select ".manuscript__summary", text: "A duel at dawn."
  end

  test "people not in the Chapter can't edit it" do
    sign_in_as(accounts(:builder))
    patch scene_summary_path(scenes(:duel)), params: { summary: "Nonsense" }
    assert_nil scenes(:duel).reload.summary
  end

  test "a private Chapter's summary doesn't show to people who can't read it" do
    scenes(:tea).update_summary!("Secret plans over tea.", by: characters(:moth))
    sign_in_as(accounts(:bob))
    get room_path(scenes(:tea).room)
    assert_select ".scene-list__summary", count: 0
  end
end
