# The Founder's Wells page: this game and the other Wells (games) started
# from it, which version each runs, the versions marked ready, and buttons to
# update them or start a new Well. Only the Founder sees it. See docs/wells.md.
class Admin::WellsController < Admin::BaseController
  before_action :require_founder
  limit_posting to: 3, within: 10.minutes, only: :create

  def show
    load_page
  end

  # Starts a new Well on this droplet with the newest version marked ready.
  def create
    github = GithubActions.current
    @well = Well.new(params.expect(well: %i[ name slug ]).merge(account: current_account))
    @well.domain = "#{@well.slug.to_s.strip.downcase}.#{base_domain}"
    return redirect_to(admin_wells_path, alert: "Wait for the running update to finish first.") if WellUpdate.running.exists? || WellUpdate.waiting_turn.exists?

    newest = github.releases.first
    return redirect_to(admin_wells_path, alert: "No version is marked ready yet.") unless newest
    unless params[:confirm_name].to_s.strip == @well.name.to_s.strip
      @well.errors.add(:base, "Type the Well's name again to confirm.")
      load_page
      return render(:show, status: :unprocessable_entity)
    end

    if @well.save
      @well.well_updates.create!(account: current_account, version: newest.tag, request_id: SecureRandom.hex(4), first_time: true).start!(github)
      redirect_to admin_wells_path, notice: "Starting #{@well.name} at #{@well.domain}. This page shows how it's going."
    else
      load_page
      render :show, status: :unprocessable_entity
    end
  rescue GithubActions::Error => error
    redirect_to admin_wells_path, alert: error.message
  end

  private
    def base_domain = ENV.fetch("APP_HOST", "inkwll.com")

    def load_page
      github = GithubActions.current
      @home_url = ENV["INKWLL_HOME_URL"].presence
      @configured = github.configured?
      @current_version = ENV.fetch("INKWLL_VERSION", "").presence
      @wells = Well.listed.to_a
      @well ||= Well.new
      @base_domain = base_domain
      @updates = WellUpdate.recent.includes(:account, :well).to_a
      @releases = []
      return unless @configured

      @updates.select(&:running?).each { |update| update.refresh!(github) }
      WellUpdate.start_next!(github)
      @updates = WellUpdate.recent.includes(:account, :well).to_a
      @wells = Well.listed.to_a
      @releases = github.releases
    rescue GithubActions::Error => error
      @github_error = error.message
    end
end
