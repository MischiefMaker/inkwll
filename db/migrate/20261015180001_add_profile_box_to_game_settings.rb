class AddProfileBoxToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :profile_box, :string, default: "top", null: false
  end
end
