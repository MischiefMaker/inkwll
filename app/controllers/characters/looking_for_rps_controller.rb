# A player switching the Looking for RP flag on (with its two short tags)
# or off for one of their own characters.
class Characters::LookingForRpsController < Characters::BaseController
  limit_posting to: 10, within: 10.minutes

  def create
    unless @character.can_play?
      return redirect_to @character, alert: "#{@character.name} needs to be approved first."
    end
    @character.look_for_rp!(i_am: params[:i_am], looking_for: params[:looking_for])
    redirect_back fallback_location: @character, notice: "#{@character.name} is looking for RP."
  rescue ActiveRecord::RecordInvalid
    redirect_back fallback_location: @character, alert: "Keep each tag to #{Character::LookingForRp::TAG_LENGTH} characters."
  end

  def destroy
    @character.stop_looking_for_rp!
    redirect_back fallback_location: @character, notice: "#{@character.name} is no longer looking for RP."
  end
end
