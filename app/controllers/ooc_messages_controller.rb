# The site-wide out-of-character chat. Guests who aren't logged in can use it
# too, to ask questions before making an account, unless the game turns
# guest chat off. To keep spam out, guests:
#
# - pick a name that isn't a player's name, kept for this browser session,
# - can't post links,
# - can't post within a few seconds of opening the chat (bots post at once),
#   and an invisible "website" field must stay empty (bots fill everything in),
# - can post at most 5 messages a minute,
# - are turned away by bans on their address and by the VPN block.
class OocMessagesController < ApplicationController
  allow_unauthenticated_access only: %i[ index create ]
  before_action :resume_session
  before_action :end_banned_session, if: -> { Current.session }
  before_action :check_guest, unless: :current_account
  limit_posting to: 10
  rate_limit to: 5, within: 1.minute, only: :create, name: "guests", unless: -> { current_account },
    with: -> { redirect_to ooc_messages_path, alert: "That's a lot of messages. Please wait a minute." }

  GUEST_WAIT = 3.seconds

  def index
    session[:guest_chat_opened_at] ||= Time.current.to_i unless current_account
  end

  def create
    @ooc_message = current_account ? current_account.ooc_messages.new(message_params) : guest_message
    @ooc_message.save if @ooc_message
    # The new message reaches every open page (including this one) through the
    # live broadcast, so here we only need to reset the form.
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: ooc_messages_path, alert: @ooc_message&.errors&.full_messages&.to_sentence.presence || @guest_problem }
    end
  end

  private
    def message_params
      params.expect(ooc_message: [ :body ])
    end

    def check_guest
      if !GameSetting.current.guest_chat?
        redirect_to new_session_path, alert: "Log in to use the OOC Chat."
      elsif (refusal = access_refusal_for)
        redirect_to new_session_path, alert: refusal
      end
    end

    # Returns the new message, or nil with @guest_problem set.
    def guest_message
      opened_at = session[:guest_chat_opened_at]
      return guest_problem("Please wait a moment and try again.") if params[:website].present? || opened_at.nil? || Time.current.to_i - opened_at < GUEST_WAIT

      if params[:guest_name]
        name = params[:guest_name].to_s.squish
        return guest_problem("Pick a name of 2 to 20 letters, numbers or spaces.") unless name.match?(/\A[A-Za-z0-9 _]{2,20}\z/)
        return guest_problem("That's a player's name. Pick another, or log in.") if Account.exists?(username: name.downcase.delete(" "))
        session[:guest_name] = name
      end
      return guest_problem("Pick a name first.") unless session[:guest_name]

      OocMessage.new(message_params.merge(guest_name: session[:guest_name], ip_address: request.remote_ip))
    end

    def guest_problem(text)
      @guest_problem = text
      nil
    end
end
