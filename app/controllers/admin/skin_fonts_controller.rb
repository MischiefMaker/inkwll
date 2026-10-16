# Admin → Look: taking away one of the game's own fonts (the ones its world
# pack brought). Wellkeepers only, like the rest of the Look page.
class Admin::SkinFontsController < Admin::BaseController
  require_job :change_game_settings

  def destroy
    settings = GameSetting.current
    font = settings.skin_fonts.find(params[:id])
    font.destroy!
    # The skin stylesheet's address changes with this, so browsers fetch it again.
    settings.update!(updated_at: Time.current)
    redirect_to edit_admin_skin_path, notice: "Removed #{font.name}."
  end
end
