# A Bank manager paying someone from the faction's Bank, once.
class Factions::BankPaymentsController < Factions::BankBaseController
  limit_posting to: 30, within: 10.minutes

  def create
    payee = Economy.find_payee(params[:to], current_account)
    return back(alert: "There's no character or #{Term[:faction].downcase} called #{params[:to].to_s.squish}.") unless payee
    amount = params[:amount].to_i
    Economy.transfer!(from: @bank, to: payee, amount: amount, kind: "payment", note: params[:note], actor: current_account, actor_character: @manager)
    Economy.alert!(payee, "The #{@faction.name} #{Economy.bank_word} paid #{payee.bank? ? "the #{payee.owner_name} #{Economy.bank_word}" : "you"} #{Economy.money(amount)}#{": #{params[:note].to_s.squish.first(100)}" if params[:note].present?}.")
    back(notice: "Paid #{payee.owner_name} #{Economy.money(amount)} from the #{Economy.bank_word.downcase}.")
  rescue Economy::Error => e
    back(alert: e.message)
  end
end
