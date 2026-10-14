# Switches each of the game's systems on or off. Nothing is deleted when a
# system is off; it's hidden until it's switched back on.
class Admin::FeaturesController < Admin::BaseController
  require_job :change_game_settings

  def edit
    @game_setting = GameSetting.current
  end

  def update
    @game_setting = GameSetting.current
    if @game_setting.update(params.expect(game_setting: %i[ soul_enabled inklings_enabled grimoire_enabled wiki_enabled guest_chat ]))
      redirect_to edit_admin_features_path, notice: "Features saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
