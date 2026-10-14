# Paths can point a compass direction, down to the 16 points like NNW
# (owner, 2026-10-14). Optional: Paths without one work as before.
class AddDirectionToExits < ActiveRecord::Migration[8.1]
  def change
    add_column :exits, :direction, :string
    add_column :game_settings, :compass_enabled, :boolean, default: false, null: false
  end
end
