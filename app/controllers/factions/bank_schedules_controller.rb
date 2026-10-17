# A Bank manager setting up a scheduled payment from the faction's Bank
# (such as a salary for each guard), stopping one, or turning down one paid
# into it.
class Factions::BankSchedulesController < Factions::BankBaseController
  limit_posting to: 30, within: 10.minutes

  def create
    payee = Economy.find_payee(params[:to], current_account)
    return back(alert: "There's no character or #{Term[:faction].downcase} called #{params[:to].to_s.squish}.") unless payee
    first = (Date.parse(params[:starts_on].to_s) rescue nil)
    schedule = Economy::Schedule.new(from_account: @bank, to_account: payee, amount: params[:amount], interval: params[:interval],
      next_due_on: first && first >= Date.current ? first : Date.tomorrow, ends_on: params[:ends_on].presence,
      note: params[:note].to_s.squish.presence, created_by: current_account, created_by_character: @manager)
    if schedule.save
      Economy.alert!(payee, "The #{@faction.name} #{Economy.bank_word} will pay #{payee.bank? ? "the #{payee.owner_name} #{Economy.bank_word}" : "you"} #{Economy.money(schedule.amount)} #{schedule.interval_name}.")
      back(notice: "#{Economy.money(schedule.amount)} will go to #{payee.owner_name} #{schedule.interval_name}, starting #{schedule.next_due_on.to_fs(:long)}.")
    else
      back(alert: schedule.errors.full_messages.to_sentence)
    end
  end

  def destroy
    schedule = Economy::Schedule.running.where(from_account: @bank).or(Economy::Schedule.running.where(to_account: @bank)).find(params[:id])
    if schedule.from_account_id == @bank.id
      schedule.stop!("Stopped by #{signed_by}")
      Economy.alert!(schedule.to_account, "The #{@faction.name} #{Economy.bank_word} stopped its payment of #{Economy.money(schedule.amount)} #{schedule.interval_name}.")
    else
      schedule.stop!("Turned down by #{signed_by}")
      Economy.alert!(schedule.from_account, "The #{@faction.name} #{Economy.bank_word} turned down the payment of #{Economy.money(schedule.amount)} #{schedule.interval_name}.") if schedule.from_account
    end
    back(notice: "Stopped.")
  end
end
