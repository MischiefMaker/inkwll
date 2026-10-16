# One press of Update on the Founder's Wells page. GitHub does the work; this
# row remembers which run it was so the page can show how it's going.
class WellUpdate < ApplicationRecord
  belongs_to :account
  belongs_to :well, optional: true # Empty for this game itself.

  # A run GitHub hasn't shown up after this long never started.
  LOST_AFTER = 15.minutes

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :running, -> { where(status: %w[ requested queued in_progress waiting pending ]).where(created_at: 2.hours.ago..) }
  # Update all sends one at a time; the rest wait here for their turn.
  scope :waiting_turn, -> { where(status: "waiting_turn").where(created_at: 2.hours.ago..).order(:id) }

  def well_name = well&.name || "This game"

  # Sends the next waiting update once nothing else is running.
  def self.start_next!(github = GithubActions.current)
    return if running.exists?
    waiting_turn.first&.start!(github)
  end

  # Asks GitHub to run it.
  def start!(github = GithubActions.current)
    update!(status: "requested", created_at: Time.current)
    github.start_update(version: version, request_id: request_id, well: well, first_time: first_time)
  rescue GithubActions::Error
    update!(status: "failed_to_start")
    raise
  end

  def running? = status.in?(%w[ requested queued in_progress waiting pending ]) && created_at > 2.hours.ago

  # Asks GitHub how the run is going.
  def refresh!(github = GithubActions.current)
    run = run_id ? github.run(run_id) : github.find_run(request_id)
    if run
      update!(run_id: run.id, run_url: run.url, status: run.status, conclusion: run.conclusion)
    elsif created_at < LOST_AFTER.ago
      update!(status: "lost")
    end
    record_on_well
  end

  def state_label
    case status
    when "requested", "queued", "waiting", "pending" then "Waiting to start"
    when "in_progress" then "Working"
    when "completed" then { "success" => "Done", "cancelled" => "Cancelled" }.fetch(conclusion, "Failed")
    when "waiting_turn" then "Waiting its turn"
    when "lost" then "Never started"
    when "failed_to_start" then "Couldn't start"
    else running? ? "Working" : "Unknown"
    end
  end

  # For the CSS class: done, failed or working.
  def state_kind
    return "working" if running? || status == "waiting_turn"
    status == "completed" && conclusion == "success" ? "done" : "failed"
  end

  private
    # A finished run tells the Well which version it now runs, or that
    # starting it failed.
    def record_on_well
      return unless well && !running?
      if status == "completed" && conclusion == "success"
        well.update!(version: version, status: "live")
      elsif first_time && well.status == "starting"
        well.update!(status: "failed")
      end
    end
end
