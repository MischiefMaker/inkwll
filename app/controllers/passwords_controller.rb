# "Forgot your password?": emails a link that lets the player pick a new one.
# The link works for 15 minutes and only once (it stops working when the
# password changes). Staff can also make a link for a player who has no
# email (Admin::AccountsController#reset_link); that one works for a day.
class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_account_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    if (account = Account.find_by(email: params[:email].to_s.strip.downcase))
      PasswordsMailer.reset(account).deliver_later
    end
    # The same answer either way, so the form can't be used to find out who plays here.
    redirect_to new_session_path, notice: "If that email belongs to an account, we've sent a link to reset the password."
  end

  def edit
  end

  # A blank password would save nothing, so it's turned away rather than
  # reported as changed.
  def update
    if params[:password].blank?
      redirect_to edit_password_path(params[:token]), alert: "Pick a new password."
    elsif @account.update(params.permit(:password, :password_confirmation))
      @account.sessions.destroy_all
      redirect_to new_session_path, notice: "Password changed. You can log in now."
    else
      redirect_to edit_password_path(params[:token]), alert: @account.errors.full_messages.to_sentence
    end
  end

  private
    def set_account_by_token
      @account = Account.find_by_password_reset_token(params[:token]) ||
        Account.find_by_token_for(:staff_password_reset, params[:token])
      unless @account
        redirect_to new_password_path, alert: "That reset link has expired or already been used. Please ask for a new one."
      end
    end
end
