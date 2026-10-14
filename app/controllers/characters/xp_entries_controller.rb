# Staff giving XP to a character, or taking some away to fix a mistake.
class Characters::XpEntriesController < ApplicationController
  include SoulRequired

  def create
    return head :forbidden unless current_account.can?(:review_apps)
    character = Character.find(params[:character_id])
    amount = params[:amount].to_i
    note = params[:note].to_s.strip

    if amount.zero? || note.blank?
      redirect_to character_path(character, tab: "soul"), alert: "Give an amount and a reason."
    elsif amount.positive?
      character.award_xp!(amount, source: "staff", actor: current_account, note: note.first(200))
      Soul::AuditEntry.record!("xp_award", "Gave #{amount} XP", actor: current_account, character: character, reason: note)
      redirect_to character_path(character, tab: "soul"), notice: "#{amount} XP given to #{character.name}."
    else
      character.correct_xp!(amount, actor: current_account, note: note.first(200))
      Soul::AuditEntry.record!("xp_correction", "Took #{-amount} XP", actor: current_account, character: character, reason: note)
      redirect_to character_path(character, tab: "soul"), notice: "#{-amount} XP taken from #{character.name}."
    end
  end
end
