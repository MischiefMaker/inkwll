# A Chapter's Storyteller suggesting XP for one of its players. Staff
# approve or turn it down under Admin → SOUL requests.
class Scenes::AwardSuggestionsController < ApplicationController
  include SoulRequired
  limit_posting to: 10, within: 10.minutes

  def create
    scene = Scene.find(params[:scene_id])
    raise ActiveRecord::RecordNotFound unless scene.visible_to?(current_account)
    return head :forbidden unless scene.participants_for(current_account).any?(&:storyteller?)

    character = scene.participants.map(&:character).find { |c| c.id == params[:character_id].to_i && c.account_id != current_account.id }
    return redirect_to(scene, alert: "Pick another player's character in this #{Term[:scene]}.") unless character

    suggestion = scene.award_suggestions.new(character: character, suggested_by: current_account, amount: params[:amount], reason: params[:reason].to_s.strip)
    if suggestion.save
      redirect_to scene, notice: "Sent to staff: #{suggestion.amount} XP for #{character.name}."
    else
      redirect_to scene, alert: suggestion.errors.full_messages.to_sentence
    end
  end
end
