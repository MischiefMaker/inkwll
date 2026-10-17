require "test_helper"

class ChapterSpeedTest < ActionDispatch::IntegrationTest
  test "a player switches a Chapter to live chat; it takes the chat look and Enter posts" do
    sign_in_as(accounts(:alice))
    patch scene_path(scenes(:duel)), params: { scene: { speed: "live" } }
    assert_equal "live", scenes(:duel).reload.speed
    get scene_path(scenes(:duel))
    assert_select "article.scene.scene--layout-chat.scene--speed-live"
    assert_select "form[data-composer-enter-posts-value=true]"
    assert_select ".scene__speed", text: "Live chat"
  end

  test "forum speed takes the forum look with a big box, and back to the game's usual look" do
    sign_in_as(accounts(:alice))
    patch scene_path(scenes(:duel)), params: { scene: { speed: "forum" } }
    get scene_path(scenes(:duel))
    assert_select "article.scene.scene--layout-forum"
    assert_select ".composer textarea[rows='10']"

    patch scene_path(scenes(:duel)), params: { scene: { speed: "" } }
    assert_nil scenes(:duel).reload.speed
    get scene_path(scenes(:duel))
    assert_select "article.scene.scene--layout-#{GameSetting.current.chapter_layout}"
  end

  test "people not in the Chapter can't change its speed" do
    sign_in_as(accounts(:builder))
    patch scene_path(scenes(:duel)), params: { scene: { speed: "live" } }
    assert_nil scenes(:duel).reload.speed
  end
end
