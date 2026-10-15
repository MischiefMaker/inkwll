# The Founder's Wells page: which version this Well runs, the versions marked
# ready, and Update buttons. Only the Founder sees it. See docs/wells.md.
class Admin::WellsController < Admin::BaseController
  before_action :require_founder

  def show
    github = GithubActions.current
    @configured = github.configured?
    @current_version = ENV.fetch("INKWLL_VERSION", "").presence
    @updates = WellUpdate.recent.includes(:account).to_a
    @releases = []
    return unless @configured

    @updates.select(&:running?).each { |update| update.refresh!(github) }
    @releases = github.releases
  rescue GithubActions::Error => error
    @github_error = error.message
  end
end
