# Version 2.0: the random scene bounty. Each week every player gets a short
# list of characters (new ones always included); a finished Chapter with one
# of them earns bonus SOUL XP. The list is kept so it stays the same all week.
class CreateSceneBounties < ActiveRecord::Migration[8.1]
  def change
    create_table :scene_bounties do |t|
      t.references :account, null: false, foreign_key: true
      t.date :week_of, null: false
      t.bigint :character_ids, array: true, null: false, default: []
      t.timestamps
    end
    add_index :scene_bounties, [ :account_id, :week_of ], unique: true
  end
end
