# Automatic weather: off until a game switches it on. When staff haven't
# written today's weather, the game makes its own from the in-game season.
class AddWeatherToGameSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :game_settings, :weather_auto, :boolean, default: false, null: false
    add_column :game_settings, :weather_southern, :boolean, default: false, null: false
  end
end
