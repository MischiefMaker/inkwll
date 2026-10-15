# Locks the game: only staff can get in until it is unlocked. Guests and
# players see a page saying the game is locked (see ApplicationController).
class Admin::GameLocksController < Admin::BaseController
  require_job :change_game_settings

  def create
    GameSetting.current.update!(locked: true)
    redirect_to admin_root_path, notice: "The game is locked. Guests and players now see a locked page."
  end

  def destroy
    GameSetting.current.update!(locked: false)
    redirect_to admin_root_path, notice: "The game is unlocked."
  end
end
