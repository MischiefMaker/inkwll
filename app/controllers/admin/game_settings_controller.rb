# Game-wide switches. Only Wellkeepers can change them.
class Admin::GameSettingsController < Admin::BaseController
  require_job :change_game_settings

  def edit
    @game_setting = GameSetting.current
  end

  def update
    @game_setting = GameSetting.current
    if @game_setting.update(params.expect(game_setting: [ :email_required, :approval_required, :require_description, :require_icon,
      :guest_chat, :players_public, :soul_enabled, :ic_today, :ic_days_per_day, :weather, :auto_skip, :turn_minutes, :idle_days, :auto_finish_days, :roster_idle_days ]))
      redirect_to edit_admin_game_settings_path, notice: "Game settings saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
