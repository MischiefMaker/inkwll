module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
      end_banned_session if Current.session
    end

    # A ban ends any session the player already has.
    def end_banned_session
      if (ban = Ban.for(account: Current.session.account, ip: request.remote_ip))
        terminate_session
        redirect_to new_session_path, alert: ban_message(ban)
      end
    end

    # Bans, plus the optional block on known VPN addresses, keep people from
    # logging in or signing up.
    def access_refusal_for(account = nil)
      if (ban = Ban.for(account: account, ip: request.remote_ip))
        ban_message(ban)
      elsif GameSetting.current.block_vpns? && VpnRange.covers?(request.remote_ip)
        "This game doesn't allow logging in or signing up from a VPN right now. Please switch it off and try again."
      end
    end

    def ban_message(ban)
      "You're banned from this game #{ban.duration_in_words}. Reason: #{ban.reason}"
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(account)
      account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
