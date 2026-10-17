# "Looking for a scene": a player whose character is Looking for RP sends one
# quiet alert to every other player who is too. Once every few hours.
class Characters::LookingForRpNudgesController < Characters::BaseController
  limit_posting to: 3, within: 10.minutes

  def create
    unless @character.nudgeable?
      return redirect_back fallback_location: looking_for_rp_path, alert: "You can only nudge everyone once every #{Character::LookingForRp::NUDGE_EVERY.inspect}, while #{@character.name} is looking for RP."
    end
    told = @character.nudge_everyone_looking!
    redirect_back fallback_location: looking_for_rp_path,
      notice: told.zero? ? "Nobody else is looking right now, but #{@character.name} is on the list." : "Nudged #{helpers.pluralize(told, "player")} who #{told == 1 ? "is" : "are"} looking for RP."
  end
end
