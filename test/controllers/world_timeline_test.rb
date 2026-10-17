require "test_helper"

class WorldTimelineTest < ActionDispatch::IntegrationTest
  setup do
    @scene = scenes(:duel)
    @scene.update!(finished_at: Time.current, ic_date: Date.new(1203, 5, 1))
  end

  test "builders put a finished Chapter on the timeline, and everyone reads it" do
    sign_in_as(accounts(:builder))
    get scene_path(@scene)
    assert_select ".world-event__form"
    post admin_scene_world_event_path(@scene), params: { world_event_note: "The duel that ended the feud." }
    assert @scene.reload.world_event?
    sign_out

    get timeline_path
    assert_response :success
    assert_select ".timeline__year-title", text: "1203"
    assert_select ".timeline__title", text: @scene.title
    assert_select ".timeline__note", text: "The duel that ended the feud."

    sign_in_as(accounts(:builder))
    delete admin_scene_world_event_path(@scene)
    assert_not @scene.reload.world_event?
  end

  test "players and other staff are turned away, and open Chapters can't be added" do
    sign_in_as(accounts(:alice))
    post admin_scene_world_event_path(@scene)
    assert_not @scene.reload.world_event?
    sign_out

    @scene.update!(finished_at: nil)
    sign_in_as(accounts(:builder))
    post admin_scene_world_event_path(@scene)
    assert_not @scene.reload.world_event?
  end

  test "hidden Chapters stay off the timeline for people who can't see them" do
    scenes(:secret).update_columns(world_event_at: Time.current, finished_at: Time.current)
    get timeline_path
    assert_select ".timeline__title", text: scenes(:secret).title, count: 0
  end
end
