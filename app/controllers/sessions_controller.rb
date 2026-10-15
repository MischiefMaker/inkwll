class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  # Staff log in here while the game is locked, and anyone can log out.
  skip_before_action :enforce_game_lock
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if account = Account.log_in(params[:username], params[:password])
      if (refusal = access_refusal_for(account))
        return redirect_to new_session_path, alert: refusal
      end
      start_new_session_for account
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Wrong player name or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
