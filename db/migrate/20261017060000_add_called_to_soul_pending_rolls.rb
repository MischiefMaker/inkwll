# Remembers whether the Storyteller called for a roll (true) or the player
# asked the Storyteller to judge one (false), so the waiting box can say which.
class AddCalledToSoulPendingRolls < ActiveRecord::Migration[8.1]
  def change
    add_column :soul_pending_rolls, :called, :boolean, default: false, null: false
  end
end
