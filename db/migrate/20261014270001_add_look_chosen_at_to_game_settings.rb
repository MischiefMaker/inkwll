# New games start in the default look until an admin picks one (owner, 2026-10-14).
class AddLookChosenAtToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :look_chosen_at, :datetime
  end
end
