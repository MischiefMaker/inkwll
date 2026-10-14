# The game's skin as a stylesheet, loaded on every page after the built-in
# one. Its address carries a version number, so browsers can keep it until
# the skin changes.
class SkinsController < ApplicationController
  allow_unauthenticated_access

  def show
    settings = GameSetting.current
    expires_in 1.year, public: true if params[:v] == settings.updated_at.to_i.to_s
    render plain: settings.skin_css, content_type: "text/css"
  end
end
