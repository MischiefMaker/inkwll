# A Storyteller's ruling on a waiting roll: which Boons and Banes must count,
# which the player may choose to count, and who judged it. The roll then waits
# ("ready") for the player to pick their optional ones and roll.
class AddBnbChoicesToSoulPendingRolls < ActiveRecord::Migration[8.1]
  def change
    add_column :soul_pending_rolls, :mandatory_bnb_ids, :integer, array: true, default: [], null: false
    add_column :soul_pending_rolls, :optional_bnb_ids, :integer, array: true, default: [], null: false
    add_column :soul_pending_rolls, :judge_id, :bigint
  end
end
