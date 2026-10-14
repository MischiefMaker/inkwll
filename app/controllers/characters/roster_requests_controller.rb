# A player asking staff to put their own character on the roster now, rather
# than waiting for it to go idle. Staff approve or decline it on the
# admin Roster page.
class Characters::RosterRequestsController < Characters::BaseController
  limit_posting to: 5, within: 10.minutes

  def create
    @character.request_roster! unless @character.retired? || @character.roster_requested?
    redirect_to @character, notice: "Asked staff to put #{@character.name} on the roster."
  end

  def destroy
    @character.update!(roster_requested_at: nil)
    redirect_to @character, notice: "Withdrawn. #{@character.name} stays yours."
  end
end
