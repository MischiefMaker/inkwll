# Update on the Wells page: asks GitHub to deploy a version marked ready to
# this game, to one other Well, or to every Well one after another. Only the
# Founder can, one update at a time.
class Admin::WellUpdatesController < Admin::BaseController
  before_action :require_founder
  limit_posting to: 5, within: 10.minutes, only: :create

  def create
    github = GithubActions.current
    version = params.require(:version).to_s
    return redirect_to(admin_wells_path, alert: "An update is already running. Wait for it to finish.") if WellUpdate.running.exists? || WellUpdate.waiting_turn.exists?
    return redirect_to(admin_wells_path, alert: "#{version} isn't a version marked ready.") unless github.releases.any? { |release| release.tag == version }

    # This game goes first, then the other Wells in the order they started.
    # nil stands for this game. With "every Well", anything already on this
    # version is left out.
    targets = if params[:all].present?
      Well.listed.where(status: "live").where.not(version: version).to_a.tap { |wells| wells.unshift(nil) unless ENV["INKWLL_VERSION"] == version }
    else
      [ params[:well_id].presence && Well.find(params[:well_id]) ]
    end
    return redirect_to(admin_wells_path, notice: "Every Well is already on #{version}.") if targets.empty?
    updates = targets.map do |well|
      WellUpdate.create!(account: current_account, well: well, version: version, request_id: SecureRandom.hex(4), status: "waiting_turn")
    end
    updates.first.start!(github)
    redirect_to admin_wells_path, notice: updates.one? ? "Updating #{updates.first.well_name} to #{version}. This page shows how it's going." : "Updating every Well to #{version}, one after another. Keep this page open; it starts each one when the last is done."
  rescue GithubActions::Error => error
    WellUpdate.waiting_turn.update_all(status: "failed_to_start")
    redirect_to admin_wells_path, alert: error.message
  end
end
