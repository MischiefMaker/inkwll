# Boons and Banes that change the weekly allowance, such as "Wealthy" (+10)
# or "Penniless" (-5). Only while SOUL is on.
class Admin::EconomyAllowanceChangesController < Admin::BaseController
  include EconomyRequired
  require_job :change_game_settings

  def create
    change = Economy::AllowanceChange.find_or_initialize_by(soul_bnb_id: params[:soul_bnb_id])
    change.amount = params[:amount]
    if change.save
      redirect_to admin_economy_path, notice: "#{change.bnb.name} now changes the allowance by #{change.amount.positive? ? "+" : ""}#{change.amount}."
    else
      redirect_to admin_economy_path, alert: change.errors.full_messages.to_sentence
    end
  end

  def destroy
    Economy::AllowanceChange.find(params[:id]).destroy!
    redirect_to admin_economy_path, notice: "Removed."
  end
end
