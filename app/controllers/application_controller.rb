class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_account, :current_character, :guest_chat_open?
  before_action :note_last_seen
  # New players waiting for staff approval only see the waiting page.
  before_action :hold_unapproved_player
  # While the game is locked, only staff get in. Runs before the login check so
  # guests see the locked page too.
  before_action :enforce_game_lock, prepend: true

  # Hitting a posting limit this many times within MUTE_FOR mutes someone
  # for MUTE_FOR. Staff can see and lift mutes on the player's admin page.
  MUTE_AFTER_STRIKES = 3
  MUTE_FOR = 10.minutes

  # Slows down anyone posting faster than a person could, counted per
  # account (or per address for guests), so a script can't flood the game.
  # Someone who keeps hitting the limit is muted for a while.
  def self.limit_posting(to:, within: 1.minute, only: :create, name: "posting")
    before_action :refuse_while_muted, only: only
    rate_limit to: to, within: within, only: only, name: name, by: -> { current_account&.id || request.remote_ip },
      with: -> {
        note_posting_strike
        redirect_back fallback_location: root_path, alert: "You're posting very fast. Please wait a minute and try again."
      }
  end


  private
    def current_account
      Current.account
    end

    def current_character
      current_account&.active_character
    end

    # Whether a visitor who isn't logged in sees the OOC Chat beside the page:
    # only when the game allows guest chat and their address isn't banned.
    # Showing it starts the short wait before a guest can post (see
    # OocMessagesController), just as opening the chat page does.
    def guest_chat_open?
      return @guest_chat_open if defined?(@guest_chat_open)
      settings = GameSetting.current
      @guest_chat_open = settings.guest_chat? && !settings.private_game? && !settings.locked? && !Ban.for(account: nil, ip: request.remote_ip)
      session[:guest_chat_opened_at] ||= Time.current.to_i if @guest_chat_open
      @guest_chat_open
    end

    def hold_unapproved_player
      redirect_to account_waiting_path if current_account&.awaiting_approval?
    end

    def enforce_game_lock
      return unless GameSetting.current.locked?
      resume_session
      return if Current.session&.account&.staff?
      render "game_locks/show", layout: "locked", status: :service_unavailable
    end

    # When the player was last on the site, for "only when I'm away" emails.
    # Saved at most once a minute.
    def note_last_seen
      account = current_account
      return unless account && (account.last_seen_at.nil? || account.last_seen_at < 1.minute.ago)
      account.update_column(:last_seen_at, Time.current)
    end

    def muted_until
      current_account ? current_account.muted_until : Rails.cache.read("muted:#{request.remote_ip}")
    end

    def refuse_while_muted
      return unless (until_time = muted_until)&.future?
      redirect_back fallback_location: root_path,
        alert: "You've been posting too fast, so you're muted for #{helpers.distance_of_time_in_words(Time.current, until_time)}. Staff can lift it early."
    end

    def note_posting_strike
      key = "posting-strikes:#{current_account&.id || request.remote_ip}"
      strikes = Rails.cache.increment(key, 1, expires_in: MUTE_FOR) || 1
      return if strikes < MUTE_AFTER_STRIKES

      if current_account
        current_account.update_column(:muted_until, MUTE_FOR.from_now)
      else
        Rails.cache.write("muted:#{request.remote_ip}", MUTE_FOR.from_now, expires_in: MUTE_FOR)
      end
      Rails.cache.delete(key)
    end

    def require_character
      redirect_to new_character_path, notice: "Create a character first." unless current_character
    end
end
