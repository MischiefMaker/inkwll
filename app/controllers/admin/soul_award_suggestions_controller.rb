# Staff approving or turning down XP a Storyteller suggested.
class Admin::SoulAwardSuggestionsController < Admin::BaseController
  require_job :review_apps

  def update
    suggestion = Soul::AwardSuggestion.pending.find(params[:id])
    if params[:decision] == "approve"
      suggestion.approve!(by: current_account)
      redirect_to admin_soul_reviews_path, notice: "#{suggestion.character.name} got #{suggestion.amount} XP."
    else
      suggestion.deny!(by: current_account, reason: params[:reason])
      redirect_to admin_soul_reviews_path, notice: "Suggestion turned down."
    end
  end
end
