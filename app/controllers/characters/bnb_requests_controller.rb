# A player asking staff for a new Boon or Bane once their sheet is locked.
class Characters::BnbRequestsController < Characters::BaseController
  include SoulRequired
  limit_posting to: 5, within: 10.minutes

  def create
    bnb = Soul::Bnb.active.find(params[:bnb_id])
    request = @character.bnb_requests.new(bnb: bnb, level: params[:level].presence || "minor",
      skill_ids: Array(params[:skill_ids]).compact_blank.map(&:to_i), explanation: params[:explanation])
    if request.save
      redirect_to character_path(@character, tab: "soul"), notice: "Asked staff for #{bnb.name}."
    else
      redirect_to character_path(@character, tab: "soul"), alert: request.errors.full_messages.to_sentence
    end
  end
end
