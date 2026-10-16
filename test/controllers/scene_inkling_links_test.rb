require "test_helper"

class SceneInklingLinksTest < ActionDispatch::IntegrationTest
  setup do
    @wren = characters(:wren)
    @scene = scenes(:duel)
    @inkling = Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Win the duel", body: "Somehow.")
  end

  test "a player adds a Chapter to an Inkling with a reason, and the Inkling gets an entry linking back" do
    sign_in_as(accounts(:alice))
    assert_difference [ "InklingSceneLink.count", "InklingEntry.count" ] do
      post scene_inkling_links_path(@scene), params: { inkling_id: @inkling.id, reason: "Won first blood." }
    end
    get inkling_path(@inkling)
    assert_select ".inkling-entry__chapter-link[href=?]", scene_path(@scene), text: "Duel at Dawn"
    assert_select ".inkling-entry__body", text: /Won first blood/
    get scene_path(@scene)
    assert_select ".inkling-link-modal select option", text: /Win the duel/
  end

  test "a reason is needed" do
    sign_in_as(accounts(:alice))
    assert_no_difference "InklingEntry.count" do
      post scene_inkling_links_path(@scene), params: { inkling_id: @inkling.id, reason: " " }
    end
  end

  test "a player starts a new Inkling from a Chapter" do
    sign_in_as(accounts(:alice))
    assert_difference [ "Inkling.count", "InklingSceneLink.count" ] do
      post scene_inkling_links_path(@scene), params: { kind: "goal", title: "Settle the score", reason: "After the duel." }
    end
    assert_equal "Settle the score", Inkling.order(:id).last.title
  end

  test "someone else's Inkling, or a Chapter you are not in, is turned away" do
    sign_in_as(accounts(:bob))
    assert_no_difference "InklingEntry.count" do
      post scene_inkling_links_path(@scene), params: { inkling_id: @inkling.id, reason: "Sneaky." }
    end
    sign_in_as(accounts(:alice))
    assert_no_difference "InklingEntry.count" do
      post scene_inkling_links_path(scenes(:secret)), params: { inkling_id: @inkling.id, reason: "Sneaky." }
    end
  end

  test "other players in the Chapter don't see someone else's Inklings in the pop-up" do
    sign_in_as(accounts(:bob))
    get scene_path(@scene)
    assert_not_includes response.body, "Win the duel"
  end

  test "a finished Chapter can still be added to an Inkling" do
    @scene.update_columns(finished_at: Time.current)
    sign_in_as(accounts(:alice))
    get scene_path(@scene)
    assert_select ".inkling-link-box"
    assert_difference "InklingEntry.count" do
      post scene_inkling_links_path(@scene), params: { inkling_id: @inkling.id, reason: "Looking back, it settled it." }
    end
  end
end
