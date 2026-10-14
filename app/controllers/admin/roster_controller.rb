# The roster: applications to take over characters, players asking to put
# their own character on it, and the characters on it now.
class Admin::RosterController < Admin::BaseController
  require_job :review_apps

  def show
    @applications = RosterApplication.pending.includes(:character, :account).order(:created_at)
    @requests = Character.active.where.not(roster_requested_at: nil).includes(:account).order(:roster_requested_at)
    @roster = Character.on_roster.includes(:roster_applications).order(:name)
  end
end
