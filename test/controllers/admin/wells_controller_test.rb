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

    def start_update(version:, request_id:) = @started << [ version, request_id ]

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
    assert_select ".wells__release--current", text: /Running now/
    assert_select "button.wells__install", text: "Update to v1.1"
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
end
