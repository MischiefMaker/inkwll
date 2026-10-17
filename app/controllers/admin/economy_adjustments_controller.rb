# Staff giving money to, or taking it from, a character's Purse or a
# faction's Bank. Always with a reason, which shows on the ledger.
class Admin::EconomyAdjustmentsController < Admin::BaseController
  include EconomyRequired
  require_job :review_apps
  limit_posting to: 60, within: 10.minutes

  def create
    account = Economy.find_payee(params[:to], current_account)
    return redirect_to(admin_economy_path, alert: "There's no character or #{Term[:faction].downcase} called #{params[:to].to_s.squish}.") unless account
    reason = params[:reason].to_s.squish
    return redirect_to(admin_economy_path, alert: "Give a reason. It shows on the ledger.") if reason.blank?

    amount = params[:amount].to_i
    if params[:direction] == "take"
      account.debit!(amount, kind: "staff_take", note: reason, actor: current_account)
      redirect_to admin_economy_path, notice: "Took #{Economy.money(amount)} from #{account.owner_name}."
    else
      account.credit!(amount, kind: "staff", note: reason, actor: current_account)
      Economy.alert!(account, "Staff gave #{account.bank? ? "the #{account.owner_name} #{Economy.bank_word}" : account.owner_name} #{Economy.money(amount)}: #{reason.first(100)}.")
      redirect_to admin_economy_path, notice: "Gave #{account.owner_name} #{Economy.money(amount)}."
    end
  rescue Economy::Error => e
    redirect_to admin_economy_path, alert: e.message
  end
end
