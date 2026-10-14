# Culminations: a player proposes a milestone for their character, and
# staff approve, deny or later revoke it.
class Characters::CulminationsController < ApplicationController
  include SoulRequired
  limit_posting to: 5, within: 10.minutes

  def create
    character = current_account.characters.find(params[:character_id])
    culmination = character.culminations.new(title: params[:title], description: params[:description])
    if culmination.save
      redirect_to character_path(character, tab: "soul"), notice: "Proposed. Staff will take a look."
    else
      redirect_to character_path(character, tab: "soul"), alert: culmination.errors.full_messages.to_sentence
    end
  end

  def update
    return head :forbidden unless current_account.can?(:review_apps)
    character = Character.find(params[:character_id])
    culmination = character.culminations.find(params[:id])
    decision = params[:decision].presence_in(%w[ approved denied revoked ]) or return head :bad_request
    culmination.update!(status: decision, staff_reason: params[:reason].to_s.strip.first(250).presence, reviewed_by: current_account, reviewed_at: Time.current)
    character.note_history!("culmination", "Reached a Culmination: #{culmination.title}.") if decision == "approved"
    character.note_history!("culmination", "The Culmination \"#{culmination.title}\" was withdrawn.") if decision == "revoked"
    Soul::AuditEntry.record!("culmination_#{decision}", "Culmination #{decision}: #{culmination.title}", actor: current_account, character: character, reason: params[:reason])
    redirect_back fallback_location: character_path(character, tab: "soul"), notice: "Culmination #{decision}."
  end
end
