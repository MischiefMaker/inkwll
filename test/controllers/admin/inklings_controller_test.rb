require "test_helper"

class Admin::InklingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wren = characters(:wren)
    @recent = Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Recent plan", body: "x", staff_visible: true)
    @old = Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Old plan", body: "x", staff_visible: true)
    @old.update_columns(created_at: 200.days.ago, last_entry_at: 200.days.ago)
  end

  test "the list shows Inklings active in the last 90 days, with a cut-off staff can change" do
    sign_in_as(accounts(:scribe))
    get admin_inklings_path
    assert_select ".inklings-admin__item a", text: "Recent plan"
    assert_select ".inklings-admin__item a", text: "Old plan", count: 0
    get admin_inklings_path(days: 365)
    assert_select ".inklings-admin__item a", text: "Old plan"
    get admin_inklings_path(days: 0)
    assert_select ".inklings-admin__item a", text: "Old plan"
    get admin_inklings_path(days: 7)
    assert_select ".inklings-admin__item a", text: "Old plan", count: 0
  end

  test "the list is paginated and keeps the cut-off between pages" do
    stub_const = Admin::InklingsController::PER_PAGE
    (stub_const + 1).times { |n| Inkling.start!(character: @wren, by: accounts(:alice), kind: "goal", title: "Filler #{n}", body: "x", staff_visible: true) }
    sign_in_as(accounts(:scribe))
    get admin_inklings_path(days: 180)
    assert_select ".inklings-admin__item", count: stub_const
    assert_select ".forum-pages a[href*='days=180'][href*='page=2']"
    get admin_inklings_path(days: 180, page: 2)
    assert_select ".inklings-admin__item", count: 2
  end

  test "a player is turned away from the admin Inklings list" do
    sign_in_as(accounts(:alice))
    get admin_inklings_path
    assert_redirected_to root_path
  end
end
