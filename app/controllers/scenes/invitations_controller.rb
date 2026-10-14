# Characters in a private or hidden Chapter can invite others by name.
class Scenes::InvitationsController < Scenes::BaseController
  limit_posting to: 20
  before_action :require_participant

  def create
    character = Character.find_by("LOWER(name) = ?", params[:name].to_s.squish.downcase)
    if character.nil?
      redirect_to @scene, alert: "There's no character called \"#{params[:name]}\"."
    elsif @scene.participant_for(character)
      redirect_to @scene, alert: "#{character.name} is already in this #{Term[:scene]}."
    else
      @scene.invitations.find_or_create_by!(character: character)
      redirect_to @scene, notice: "#{character.name} is invited."
    end
  end
end
