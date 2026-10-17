require "test_helper"

class SceneIdeasTest < ActionDispatch::IntegrationTest
  test "staff who build add ideas, and the new Chapter form offers them" do
    sign_in_as(accounts(:scribe))
    post admin_scene_ideas_path, params: { scene_idea: { title: "A stranger asks for directions", subtitle: "Not everything adds up." } }
    assert SceneIdea.exists?(title: "A stranger asks for directions")

    sign_in_as(accounts(:alice))
    get room_path(characters(:wren).room)
    assert_select ".new-scene__idea", text: "Give me an idea"
    assert_select "form[data-scene-idea-ideas-value*='A stranger asks for directions']"
  end

  test "no button without ideas" do
    sign_in_as(accounts(:alice))
    get room_path(characters(:wren).room)
    assert_select ".new-scene__idea", count: 0
  end

  test "players can't add or delete ideas" do
    idea = SceneIdea.create!(title: "Keep me")
    sign_in_as(accounts(:alice))
    post admin_scene_ideas_path, params: { scene_idea: { title: "Mine" } }
    delete admin_scene_idea_path(idea)
    assert_not SceneIdea.exists?(title: "Mine")
    assert SceneIdea.exists?(idea.id)
  end
end
