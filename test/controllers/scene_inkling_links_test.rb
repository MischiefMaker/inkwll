require "test_helper"

class SceneInklingLinksTest < ActionDispatch::IntegrationTest
  setup do
    @wren = characters(:wren)
    @scene = scenes(:duel)
    @inkling = Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Win the duel", body: "Somehow.")
  end

  test "a player links one of their Inklings to a Chapter they are in" do
    sign_in_as(accounts(:alice))
    assert_difference "InklingSceneLink.count" do
      post scene_inkling_links_path(@scene), params: { inkling_id: @inkling.id }
    end
    assert_includes @inkling.reload.linked_scenes, @scene
    get inkling_path(@inkling)
    assert_select ".inkling__chapter", text: "Duel at Dawn"
    get scene_path(@scene)
    assert_select ".inkling-link-box__title", text: "Win the duel"
  end

  test "a player starts a new Inkling from a Chapter" do
    sign_in_as(accounts(:alice))
    assert_difference [ "Inkling.count", "InklingSceneLink.count" ] do
      post scene_inkling_links_path(@scene), params: { kind: "goal", title: "Settle the score", body: "After the duel." }
    end
    assert_equal "Settle the score", Inkling.order(:id).last.title
  end

  test "linking can be undone" do
    link = InklingSceneLink.create!(inkling: @inkling, scene: @scene, linked_by: accounts(:alice))
    sign_in_as(accounts(:alice))
    assert_difference "InklingSceneLink.count", -1 do
      delete scene_inkling_link_path(@scene, link)
    end
  end

  test "someone else's Inkling, or a Chapter you are not in, is turned away" do
    sign_in_as(accounts(:bob))
    assert_no_difference "InklingSceneLink.count" do
      post scene_inkling_links_path(@scene), params: { inkling_id: @inkling.id }
    end
    sign_in_as(accounts(:alice))
    assert_no_difference "InklingSceneLink.count" do
      post scene_inkling_links_path(scenes(:secret)), params: { inkling_id: @inkling.id }
    end
  end

  test "other players in the Chapter don't see the link" do
    InklingSceneLink.create!(inkling: @inkling, scene: @scene, linked_by: accounts(:alice))
    sign_in_as(accounts(:bob))
    get scene_path(@scene)
    assert_select ".inkling-link-box__title", count: 0
    assert_not_includes response.body, "Win the duel"
  end
end
