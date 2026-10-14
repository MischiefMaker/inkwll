require "test_helper"

class Scenes::PausesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "pausing with a note, then picking it back up" do
    post scene_pause_path(scenes(:duel)), params: { note: "Back Saturday" }
    assert_equal "Back Saturday", scenes(:duel).reload.pause_note
    get scene_path(scenes(:duel))
    assert_select ".notice-box", text: /Paused since .*Back Saturday/

    delete scene_pause_path(scenes(:duel))
    assert_not scenes(:duel).reload.paused?
  end

  test "only players in the Chapter can pause it" do
    sign_in_as(accounts(:builder))
    post scene_pause_path(scenes(:duel))
    assert_not scenes(:duel).reload.paused?
  end
end
