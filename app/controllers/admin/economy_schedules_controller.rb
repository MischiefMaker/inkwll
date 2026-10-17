# Game payments: scheduled payments staff set up that the game pays, so
# they make new money, such as a stipend for a faction's Bank.
class Admin::EconomySchedulesController < Admin::BaseController
  include EconomyRequired
  require_job :review_apps

  def create
    account = Economy.find_payee(params[:to], current_account)
    return redirect_to(admin_economy_path, alert: "There's no character or #{Term[:faction].downcase} called #{params[:to].to_s.squish}.") unless account
    first = (Date.parse(params[:starts_on].to_s) rescue nil)
    schedule = Economy::Schedule.new(to_account: account, amount: params[:amount], interval: params[:interval], note: params[:note].to_s.squish.presence,
      next_due_on: first && first >= Date.current ? first : Date.tomorrow, ends_on: params[:ends_on].presence, created_by: current_account)
    if schedule.save
      redirect_to admin_economy_path, notice: "The game will pay #{account.owner_name} #{Economy.money(schedule.amount)} #{schedule.interval_name}."
    else
      redirect_to admin_economy_path, alert: schedule.errors.full_messages.to_sentence
    end
  end

  def destroy
    Economy::Schedule.running.where(from_account_id: nil).find(params[:id]).stop!("Stopped by staff")
    redirect_to admin_economy_path, notice: "Stopped."
  end
end
