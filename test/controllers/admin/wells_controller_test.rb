require "test_helper"

class Admin::WellsControllerTest < ActionDispatch::IntegrationTest
  # Stands in for GitHub so nothing leaves the test.
  class FakeGithub
    attr_reader :started
    attr_accessor :run_status

    def initialize(configured: true)
      @configured = configured
      @started = []
      @run_status = "in_progress"
    end

    def configured? = @configured

    def releases
      [ GithubActions::Release.new(tag: "v1.1", name: "v1.1", notes: "Newer things.", published_at: 1.day.ago),
        GithubActions::Release.new(tag: "v1.0", name: "v1.0", notes: "First version.", published_at: 3.days.ago) ]
    end

    def start_update(version:, request_id:, well: nil, first_time: false)
      @started << [ version, request_id ]
      @started_for = (@started_for || []) << [ well&.slug, first_time ]
    end

    attr_reader :started_for

    def find_run(request_id)
      return unless @started.any? { |_, id| id == request_id }
      GithubActions::Run.new(id: 42, url: "https://github.com/run/42", status: run_status, conclusion: run_status == "completed" ? "success" : nil)
    end

    def run(_id) = GithubActions::Run.new(id: 42, url: "https://github.com/run/42", status: run_status, conclusion: run_status == "completed" ? "success" : nil)
  end

  setup do
    @github = FakeGithub.new
    GithubActions.current = @github
    @old_version = ENV["INKWLL_VERSION"]
    ENV["INKWLL_VERSION"] = "v1.0"
  end

  teardown do
    GithubActions.current = nil
    ENV["INKWLL_VERSION"] = @old_version
  end

  test "only the Founder sees the Wells page and its menu link" do
    sign_in_as(accounts(:wellkeeper))
    get admin_wells_path
    assert_redirected_to root_path
    get admin_root_path
    assert_select "a.admin-menu__link", text: "Wells", count: 0

    sign_in_as(accounts(:founder))
    get admin_wells_path
    assert_response :success
    assert_select "a.admin-menu__link", text: "Wells"
    assert_select ".wells__version", text: "v1.0"
    assert_select ".wells__current", text: "You are currently running v1.0."
    assert_select ".version-footer", text: "Inkwll v1.0"
    assert_select ".wells__release--current", text: /Running now/
    assert_select "button.wells__install", text: "Update to v1.1"
  end

  test "every page shows the version at the bottom, or the build for a deploy of main" do
    get root_path
    assert_select ".version-footer", text: "Inkwll v1.0"
    ENV["INKWLL_VERSION"] = "06b8e1b"
    get root_path
    assert_select ".version-footer", text: "Inkwll build 06b8e1b"
    ENV["INKWLL_VERSION"] = nil
    get root_path
    assert_select ".version-footer", count: 0
  end

  test "a Wellkeeper who isn't the Founder can't start an update" do
    sign_in_as(accounts(:wellkeeper))
    assert_no_difference("WellUpdate.count") { post admin_well_updates_path, params: { version: "v1.1" } }
    assert_empty @github.started
  end

  test "the Founder starts an update, sees it working, then done" do
    sign_in_as(accounts(:founder))
    post admin_well_updates_path, params: { version: "v1.1" }
    assert_redirected_to admin_wells_path
    update = WellUpdate.last
    assert_equal [ [ "v1.1", update.request_id ] ], @github.started

    get admin_wells_path
    assert_select ".wells__update--working", text: /Working/
    assert_select ".wells__busy", text: /Updating Inkwll to v1.1: working/
    assert_select "button.wells__install", count: 0
    assert_select "meta[http-equiv=refresh]"

    @github.run_status = "completed"
    get admin_wells_path
    assert_select ".wells__update--done", text: /Done/
    assert_equal 42, update.reload.run_id
  end

  test "only versions marked ready can be installed, one at a time" do
    sign_in_as(accounts(:founder))
    assert_no_difference("WellUpdate.count") { post admin_well_updates_path, params: { version: "main" } }
    post admin_well_updates_path, params: { version: "v1.1" }
    assert_no_difference("WellUpdate.count") { post admin_well_updates_path, params: { version: "v1.0" } }
    assert_equal 1, @github.started.size
  end

  test "without the GitHub key the page explains how to set it up" do
    GithubActions.current = FakeGithub.new(configured: false)
    sign_in_as(accounts(:founder))
    get admin_wells_path
    assert_select ".wells__setup", text: /WELLS_GITHUB_TOKEN/
    assert_select "button.wells__install", count: 0
  end

  test "a run GitHub never shows is marked as never started" do
    update = WellUpdate.create!(account: accounts(:founder), version: "v1.1", request_id: "abcd1234", created_at: 20.minutes.ago)
    sign_in_as(accounts(:founder))
    get admin_wells_path
    assert_equal "lost", update.reload.status
    assert_select ".wells__update--failed", text: /Never started/
  end

  test "the Founder starts a new Well with the newest version" do
    sign_in_as(accounts(:founder))
    post admin_wells_path, params: { well: { name: "Moonfall", slug: "moonfall" }, confirm_name: "Moonfall" }
    assert_redirected_to admin_wells_path
    well = Well.find_by!(slug: "moonfall")
    assert_equal "moonfall.inkwll.com", well.domain
    assert_equal [ [ "moonfall", true ] ], @github.started_for
    assert_equal "v1.1", well.well_updates.last.version

    @github.run_status = "completed"
    get admin_wells_path
    assert_equal "live", well.reload.status
    assert_equal "v1.1", well.version
    assert_select ".wells__setup-link code", text: well.setup_url
  end

  test "a new Well needs its name typed again and a good address" do
    sign_in_as(accounts(:founder))
    assert_no_difference("Well.count") { post admin_wells_path, params: { well: { name: "Moonfall", slug: "moonfall" }, confirm_name: "Moon" } }
    assert_no_difference("Well.count") { post admin_wells_path, params: { well: { name: "Moonfall", slug: "Moon Fall!" }, confirm_name: "Moonfall" } }
    assert_no_difference("Well.count") { post admin_wells_path, params: { well: { name: "Again", slug: "inkwll" }, confirm_name: "Again" } }
    assert_empty @github.started
  end

  test "a Wellkeeper who isn't the Founder can't start a Well" do
    sign_in_as(accounts(:wellkeeper))
    assert_no_difference("Well.count") { post admin_wells_path, params: { well: { name: "Moonfall", slug: "moonfall" }, confirm_name: "Moonfall" } }
  end

  test "Update every Well goes one at a time, this game first" do
    well = Well.create!(name: "Moonfall", slug: "moonfall", domain: "moonfall.inkwll.com", status: "live", version: "v1.0", account: accounts(:founder))
    sign_in_as(accounts(:founder))
    post admin_well_updates_path, params: { version: "v1.1", all: "1" }
    assert_equal [ [ nil, false ] ], @github.started_for
    assert_equal 1, WellUpdate.waiting_turn.count

    @github.run_status = "completed"
    get admin_wells_path
    assert_equal [ [ nil, false ], [ "moonfall", false ] ], @github.started_for
    get admin_wells_path
    assert_equal "v1.1", well.reload.version
  end

  test "another Well's page says where its updates are done" do
    ENV["INKWLL_HOME_URL"] = "https://inkwll.com"
    sign_in_as(accounts(:founder))
    get admin_wells_path
    assert_select ".wells__home a", text: "https://inkwll.com/admin/wells"
    assert_select "form.wells__new", count: 0
  ensure
    ENV["INKWLL_HOME_URL"] = nil
  end
end
