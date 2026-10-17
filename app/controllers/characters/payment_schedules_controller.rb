# A character's own scheduled payments: setting one up from their Purse
# (such as an allowance for a child), stopping one they pay, or turning
# down one paid to them.
class Characters::PaymentSchedulesController < Characters::BaseController
  include EconomyRequired
  limit_posting to: 20, within: 10.minutes

  def create
    return back(alert: "#{@character.name} can't pay anyone until they're approved.") unless @character.approved? && !@character.retired?
    payee = Economy.find_payee(params[:to], current_account)
    return back(alert: "There's no character or #{Term[:faction].downcase} called #{params[:to].to_s.squish}.") unless payee

    schedule = Economy::Schedule.new(from_account: @character.purse, to_account: payee, amount: params[:amount], interval: params[:interval],
      next_due_on: first_date, ends_on: params[:ends_on].presence, note: params[:note].to_s.squish.presence, created_by: current_account, created_by_character: @character)
    if schedule.save
      Economy.alert!(payee, "#{@character.name} set up a payment of #{Economy.money(schedule.amount)} #{schedule.interval_name} to #{payee.bank? ? "the #{payee.owner_name} #{Economy.bank_word}" : "you"}.")
      back(notice: "#{Economy.money(schedule.amount)} will go to #{payee.owner_name} #{schedule.interval_name}, starting #{schedule.next_due_on.to_fs(:long)}.")
    else
      back(alert: schedule.errors.full_messages.to_sentence)
    end
  end

  def destroy
    purse = @character.purse
    schedule = Economy::Schedule.running.where(from_account: purse).or(Economy::Schedule.running.where(to_account: purse)).find(params[:id])
    if schedule.from_account_id == purse.id
      schedule.stop!("Stopped by #{@character.name}")
      Economy.alert!(schedule.to_account, "#{@character.name} stopped their payment of #{Economy.money(schedule.amount)} #{schedule.interval_name}.")
      back(notice: "Stopped.")
    else
      schedule.stop!("Turned down by #{@character.name}")
      Economy.alert!(schedule.from_account, "#{@character.name} turned down the payment of #{Economy.money(schedule.amount)} #{schedule.interval_name}.") if schedule.from_account
      back(notice: "Turned down. It won't be paid again.")
    end
  end

  private
    def first_date
      date = Date.parse(params[:starts_on].to_s) rescue nil
      date && date >= Date.current ? date : Date.tomorrow
    end

    def back(**flash)
      redirect_to character_path(@character, tab: "purse"), **flash
    end
end
