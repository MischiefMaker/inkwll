# Update on the Wells page: asks GitHub to deploy a version marked ready to
# this Well. Only the Founder can, one update at a time.
class Admin::WellUpdatesController < Admin::BaseController
  before_action :require_founder
  limit_posting to: 5, within: 10.minutes, only: :create

  def create
    github = GithubActions.current
    version = params.require(:version).to_s
    return redirect_to(admin_wells_path, alert: "An update is already running. Wait for it to finish.") if WellUpdate.running.exists?
    return redirect_to(admin_wells_path, alert: "#{version} isn't a version marked ready.") unless github.releases.any? { |release| release.tag == version }

    update = WellUpdate.create!(account: current_account, version: version, request_id: SecureRandom.hex(4))
    begin
      github.start_update(version: version, request_id: update.request_id)
    rescue GithubActions::Error
      update.update!(status: "failed_to_start")
      raise
    end
    redirect_to admin_wells_path, notice: "Updating to #{version}. This page shows how it's going."
  rescue GithubActions::Error => error
    redirect_to admin_wells_path, alert: error.message
  end
end
