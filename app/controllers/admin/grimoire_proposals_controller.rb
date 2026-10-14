# Approving or rejecting players' spell proposals.
class Admin::GrimoireProposalsController < Admin::BaseController
  include GrimoireRequired
  require_job :review_apps

  def update
    proposal = Grimoire::Proposal.pending.find(params[:id])
    if params[:decision] == "approve"
      spell = proposal.approve!(by: current_account)
      redirect_to admin_grimoire_path, notice: "#{spell.name} is now a spell. #{proposal.character.name} can learn it with XP."
    else
      proposal.reject!(by: current_account, reason: params[:reason])
      redirect_to admin_grimoire_path, notice: "Proposal rejected."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_grimoire_path, alert: e.record.errors.full_messages.to_sentence
  end
end
