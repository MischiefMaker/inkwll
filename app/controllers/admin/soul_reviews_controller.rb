# Requests for new Boons and Banes, and proposed Culminations, waiting for staff.
class Admin::SoulReviewsController < Admin::BaseController
  require_job :review_apps

  def index
    @requests = Soul::BnbRequest.pending.includes(:character, :bnb).order(:created_at)
    @culminations = Soul::Culmination.proposed.includes(:character).order(:created_at)
    @awards = Soul::AwardSuggestion.pending.includes(:character, :scene, :suggested_by).order(:created_at)
  end

  # Approving or denying a Boon or Bane request.
  def update
    request = Soul::BnbRequest.pending.find(params[:id])
    if params[:decision] == "approve"
      request.character.add_bnb!(request.bnb, level: request.level, skill_ids: request.skill_ids, explanation: request.explanation, source: "request")
      request.update!(status: "approved", reviewed_by: current_account, reviewed_at: Time.current)
    else
      request.update!(status: "denied", staff_reason: params[:reason].to_s.strip.first(250).presence, reviewed_by: current_account, reviewed_at: Time.current)
    end
    Soul::AuditEntry.record!("request_#{request.status}", "#{request.status.capitalize} request for #{request.bnb.name}", actor: current_account, character: request.character, reason: params[:reason])
    redirect_to admin_soul_reviews_path, notice: "Request #{request.status}."
  rescue Character::SoulSheet::SheetError => e
    redirect_to admin_soul_reviews_path, alert: e.message
  end
end
