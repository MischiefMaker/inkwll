# Look-ups the game does often, or when removing a row, that had no index.
# (The Soul rating and XP "trait" columns are already covered by their
# trait_type + trait_id indexes.)
class AddMissingIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :scenes, :current_turn_participant_id
    add_index :well_updates, :request_id
    add_index :well_updates, :run_id
  end
end
