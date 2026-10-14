# Sign-up: creates a new player account and logs it in.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(params.expect(account: [ :username, :display_name, :password, :password_confirmation ]))
    if @account.save
      start_new_session_for @account
      redirect_to new_character_path, notice: "Welcome! Now create your first character."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
