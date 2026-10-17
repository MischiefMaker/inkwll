# The mini-map of the Streets, on by default; staff can switch it off.
class AddMiniMapToGameSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :game_settings, :mini_map_enabled, :boolean, default: true, null: false
  end
end
