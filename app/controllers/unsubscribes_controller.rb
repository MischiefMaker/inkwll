# The "stop these emails" link in every activity email. Works without
# logging in, using a token tied to the account.
class UnsubscribesController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :enforce_game_lock
  skip_forgery_protection only: :create
  before_action :set_account

  def show
  end

  def create
    @account.update_column(:email_notifications, "off")
    @done = true
    render :show
  end

  private
    def set_account
      @account = Account.find_by_token_for(:unsubscribe, params[:token])
      render plain: "This link has expired. You can change your email settings after logging in.", status: :not_found unless @account
    end
end
