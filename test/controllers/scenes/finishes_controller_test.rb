require "test_helper"

class Scenes::FinishesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(accounts(:alice)) }

  test "finishing and undoing" do
    post scene_finish_path(scenes(:duel))
    assert scenes(:duel).reload.finished?

    delete scene_finish_path(scenes(:duel))
    assert_not scenes(:duel).reload.finished?
  end

  test "only players in the Chapter can finish it" do
    sign_in_as(accounts(:builder))
    post scene_finish_path(scenes(:duel))
    assert_not scenes(:duel).reload.finished?
  end

  test "agreeing to make a hidden Manuscript public" do
    sign_in_as(accounts(:bob))
    scenes(:secret).finish!(by: characters(:sable))
    post scene_public_consent_path(scenes(:secret))
    assert scenes(:secret).reload.made_public_at
  end
end
