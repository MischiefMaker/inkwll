# Sign-up: creates a new player account and logs it in.
class RegistrationsController < ApplicationController
  skip_before_action :hold_unapproved_player
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @setup_code = params[:setup] if founder_setup_code?(params[:setup])
    # A Well started with "Make me its Founder too" opens with these filled in.
    @account = Account.new(@setup_code ? { display_name: params[:name].to_s.first(60), email: params[:email].to_s.first(254) } : {})
  end

  def create
    if (refusal = access_refusal_for)
      return redirect_to new_registration_path, alert: refusal
    end

    @account = Account.new(params.expect(account: [ :display_name, :email, :email_notifications, :password, :password_confirmation ]))
    @setup_code = params[:setup] if founder_setup_code?(params[:setup])
    if @setup_code
      @account.founder = true
      @account.staff_level = :wellkeeper
    end
    @account.awaiting_approval = !@setup_code && GameSetting.current.player_approval_required?
    if @account.save
      start_new_session_for @account
      if @account.awaiting_approval?
        StaffWaiting.refresh_bells!
        redirect_to account_waiting_path
      elsif @setup_code && params[:import] == "1"
        redirect_to admin_world_import_path, notice: "Welcome! Choose the world pack to import. You can make your first character afterwards."
      else
        redirect_to new_character_path, notice: "Welcome! Now create your first character."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    # A new Well's first sign-up link carries a setup code (see docs/wells.md).
    # It makes that player the Founder, and only works until there is one.
    def founder_setup_code?(code)
      expected = ENV["WELL_SETUP_CODE"].to_s
      expected.present? && code.present? && ActiveSupport::SecurityUtils.secure_compare(code.to_s, expected) && !Account.exists?(founder: true)
    end
end
