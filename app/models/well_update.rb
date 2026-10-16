# One press of Update on the Founder's Wells page. GitHub does the work; this
# row remembers which run it was so the page can show how it's going.
class WellUpdate < ApplicationRecord
  belongs_to :account

  # A run GitHub hasn't shown up after this long never started.
  LOST_AFTER = 15.minutes

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :running, -> { where(status: %w[ requested queued in_progress waiting pending ]).where(created_at: 2.hours.ago..) }

  def running? = status.in?(%w[ requested queued in_progress waiting pending ]) && created_at > 2.hours.ago

  # Asks GitHub how the run is going.
  def refresh!(github = GithubActions.current)
    run = run_id ? github.run(run_id) : github.find_run(request_id)
    if run
      update!(run_id: run.id, run_url: run.url, status: run.status, conclusion: run.conclusion)
    elsif created_at < LOST_AFTER.ago
      update!(status: "lost")
    end
  end

  def state_label
    case status
    when "requested", "queued", "waiting", "pending" then "Waiting to start"
    when "in_progress" then "Working"
    when "completed" then { "success" => "Done", "cancelled" => "Cancelled" }.fetch(conclusion, "Failed")
    when "lost" then "Never started"
    when "failed_to_start" then "Couldn't start"
    else running? ? "Working" : "Unknown"
    end
  end

  # For the CSS class: done, failed or working.
  def state_kind
    return "working" if running?
    status == "completed" && conclusion == "success" ? "done" : "failed"
  end
end
