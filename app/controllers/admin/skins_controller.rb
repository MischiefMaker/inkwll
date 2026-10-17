# Admin → Look: the game's colours, fonts and extra CSS. Wellkeepers only,
# because extra CSS can change how every page looks.
class Admin::SkinsController < Admin::BaseController
  require_job :change_game_settings

  def edit
    @game_setting = GameSetting.current
  end

  def update
    @game_setting = GameSetting.current
    if (preset = params[:preset]).present?
      return redirect_to(edit_admin_skin_path, alert: "Unknown skin.") unless GameSetting::Skin::PRESETS.key?(preset)
      @game_setting.apply_preset(preset)
    else
      @game_setting.assign_attributes(skin_params)
    end
    @game_setting.look_chosen_at ||= Time.current
    # The skin stylesheet's address changes with this, so new pictures show at once.
    @game_setting.updated_at = Time.current
    if @game_setting.save
      redirect_to edit_admin_skin_path, notice: "Look saved. Reload any open pages to see it."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def skin_params
      keys = GameSetting::Skin::COLOURS.keys
      pictures = GameSetting::Skin::PICTURES.keys.flat_map { |picture| [ picture.to_sym, :"remove_#{picture}" ] }
      params.expect(game_setting: [ :skin_dark_mode, :profile_box, :chapter_layout, :chapter_cast_portraits, :chapter_passage_portraits, :font_body, :font_heading, :font_title, :custom_css, *pictures,
        skin_colours: keys, skin_dark_colours: keys ])
    end
end
