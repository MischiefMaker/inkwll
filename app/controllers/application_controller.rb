class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_account, :current_character

  private
    def current_account
      Current.account
    end

    def current_character
      current_account&.active_character
    end

    def require_character
      redirect_to new_character_path, notice: "Create a character first." unless current_character
    end
end
