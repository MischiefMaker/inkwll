require "test_helper"

class WeeklyXpJobTest < ActiveJob::TestCase
  test "approved characters get their weekly XP once a week" do
    draft = accounts(:alice).characters.create!(name: "Drafty", status: "draft")
    sunday = Time.zone.parse("2026-10-18 00:00")
    2.times { WeeklyXpJob.perform_now(sunday) }
    assert_equal 1, characters(:wren).xp_available
    assert_equal 0, draft.xp_available

    WeeklyXpJob.perform_now(sunday + 1.week)
    assert_equal 2, characters(:wren).xp_available
  end
end
