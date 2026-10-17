# Characters signing up for an event, or dropping out, before it starts.
class Events::SignupsController < ApplicationController
  limit_posting to: 20, within: 10.minutes, only: :create
  before_action :set_event
  before_action :require_open

  def create
    character = @event.signup_choices_for(current_account).find { |c| c.id == params[:character_id].to_i }
    return redirect_to @event, alert: "Choose one of your approved characters." unless character
    @event.signups.create!(character: character)
    redirect_to @event, notice: "#{character.name} is signed up."
  end

  def destroy
    signup = @event.signups.find(params[:id])
    unless signup.character.account_id == current_account.id || @event.changeable_by?(current_account)
      return redirect_to @event, alert: "You can only take your own characters off the list."
    end
    signup.destroy!
    redirect_to @event, notice: "#{signup.character.name} is off the list."
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end

    def require_open
      redirect_to @event, alert: "Sign-ups are closed: the event has #{@event.cancelled? ? "been cancelled" : "started"}." unless @event.open_for_signups?
    end
end
