class AddLockedToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :locked, :boolean, default: false, null: false
  end
end
