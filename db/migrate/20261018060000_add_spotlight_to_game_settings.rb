# Version 2.0: the random character spotlight on the front page, on unless
# a game switches it off.
class AddSpotlightToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :character_spotlight, :boolean, default: true, null: false
  end
end
