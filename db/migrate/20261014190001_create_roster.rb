# The roster: characters other players can apply to take over. Characters on
# it belong to a built-in "Roster" account that nobody can log in to.
# Also: archiving accounts instead of deleting them.
class CreateRoster < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :system, :boolean, null: false, default: false
    add_column :accounts, :archived_at, :datetime

    add_column :characters, :on_roster_at, :datetime
    add_column :characters, :roster_note, :text
    add_column :characters, :roster_when_idle, :boolean, null: false, default: false
    add_column :characters, :roster_requested_at, :datetime
    add_index :characters, :on_roster_at

    add_column :game_settings, :roster_idle_days, :integer, null: false, default: 90

    create_table :roster_applications do |t|
      t.references :character, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.text :note, null: false
      t.string :status, null: false, default: "pending"   # pending, approved, denied
      t.string :staff_reason
      t.references :reviewed_by, foreign_key: { to_table: :accounts }
      t.datetime :reviewed_at
      t.timestamps
    end
  end
end
