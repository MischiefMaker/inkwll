class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_account, :current_character
  before_action :note_last_seen

  # Slows down anyone posting faster than a person could, counted per
  # account (or per address for guests), so a script can't flood the game.
  def self.limit_posting(to:, within: 1.minute, only: :create, name: "posting")
    rate_limit to: to, within: within, only: only, name: name, by: -> { current_account&.id || request.remote_ip },
      with: -> { redirect_back fallback_location: root_path, alert: "You're posting very fast. Please wait a minute and try again." }
  end


  private
    def current_account
      Current.account
    end

    def current_character
      current_account&.active_character
    end

    # When the player was last on the site, for "only when I'm away" emails.
    # Saved at most once a minute.
    def note_last_seen
      account = current_account
      return unless account && (account.last_seen_at.nil? || account.last_seen_at < 1.minute.ago)
      account.update_column(:last_seen_at, Time.current)
    end

    def require_character
      redirect_to new_character_path, notice: "Create a character first." unless current_character
    end
end
