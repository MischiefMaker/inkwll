require "test_helper"

class ReportsTest < ActionDispatch::IntegrationTest
  test "a player reports a Passage, and staff can then read and act on the Chapter" do
    sign_in_as(accounts(:bob))
    get new_scene_report_path(scenes(:secret))
    assert_select ".notice-box", text: /Staff will be able to read this whole chapter/

    post scene_reports_path(scenes(:secret)), params: { report: { reason: "This crossed a line." } }
    report = Report.last
    assert_equal accounts(:bob), report.account

    sign_in_as(accounts(:scribe))
    get admin_reports_path
    assert_select "a", text: "A Quiet Word"
    get scene_path(scenes(:secret))
    assert_response :success

    post admin_scene_lock_path(scenes(:secret))
    assert scenes(:secret).reload.locked?

    patch admin_report_path(report), params: { report: { resolution: "Talked to them." } }
    assert report.reload.resolved?
  end

  test "staff can't open a hidden Chapter nobody reported" do
    sign_in_as(accounts(:scribe))
    get scene_path(scenes(:secret))
    assert_response :not_found
  end

  test "staff hide a Passage; players see a note, staff still see the text" do
    scenes(:duel).reports.create!(account: accounts(:bob), pose: poses(:duel_one), reason: "Rude.")
    sign_in_as(accounts(:scribe))
    post admin_pose_hiding_path(poses(:duel_one))
    assert poses(:duel_one).reload.hidden_by_staff?

    get scene_path(scenes(:duel))
    assert_select ".pose__body", text: /Wren draws her blade/

    sign_in_as(accounts(:bob))
    get scene_path(scenes(:duel))
    assert_select ".pose__body", text: "Hidden by staff."
  end

  test "a warning shows until the player reads it" do
    sign_in_as(accounts(:scribe))
    post admin_warnings_path, params: { account_warning: { account_id: accounts(:bob).id, body: "Please keep it civil." } }
    warning = AccountWarning.last

    sign_in_as(accounts(:bob))
    get root_path
    assert_select ".staff-warning", text: /Please keep it civil/
    patch warning_path(warning)
    get root_path
    assert_select ".staff-warning", count: 0
  end

  test "Pages and players can't see reports" do
    sign_in_as(accounts(:builder))
    get admin_reports_path
    assert_redirected_to root_path
  end
end
