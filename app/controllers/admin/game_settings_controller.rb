# Game-wide switches. Only Wellkeepers can change them.
class Admin::GameSettingsController < Admin::BaseController
  require_job :change_game_settings

  def edit
    @game_setting = GameSetting.current
  end

  def update
    @game_setting = GameSetting.current
    @game_setting.update!(params.expect(game_setting: [ :email_required, :approval_required ]))
    redirect_to edit_admin_game_settings_path, notice: "Game settings saved."
  end
end
