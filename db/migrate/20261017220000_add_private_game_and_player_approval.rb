# Version 2.0: a Private Game (no guests: you must log in to see anything)
# and an optional staff approval step for new players.
class AddPrivateGameAndPlayerApproval < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :private_game, :boolean, null: false, default: false
    add_column :game_settings, :player_approval_required, :boolean, null: false, default: false
    add_column :accounts, :awaiting_approval, :boolean, null: false, default: false
  end
end
