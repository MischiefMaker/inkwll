# Step 9: Grimoire, the magic system, rebuilt from the owner's AresMUSH
# plugin. Branches of magic are tied to SOUL Skills; characters learn
# spells with XP and cast them as SOUL rolls.
class CreateGrimoire < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :grimoire_enabled, :boolean, null: false, default: false

    create_table :grimoire_branches do |t|
      t.string :name, null: false
      t.text :description
      t.references :soul_skill, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :grimoire_spells do |t|
      t.references :branch, null: false, foreign_key: { to_table: :grimoire_branches }
      t.string :name, null: false
      t.text :description
      t.integer :minimum_rating, null: false, default: 1
      t.string :difficulty_name, null: false, default: "standard"
      t.boolean :active, null: false, default: true
      t.references :created_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.timestamps
    end

    create_table :grimoire_learned_spells do |t|
      t.references :character, null: false, foreign_key: true
      t.references :spell, null: false, foreign_key: { to_table: :grimoire_spells }
      t.integer :xp_cost, null: false, default: 0
      t.timestamps
    end
    add_index :grimoire_learned_spells, %i[ character_id spell_id ], unique: true

    create_table :grimoire_proposals do |t|
      t.references :character, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: { to_table: :grimoire_branches }
      t.string :name, null: false
      t.text :description, null: false
      t.integer :minimum_rating, null: false, default: 1
      t.string :difficulty_name, null: false, default: "standard"
      t.string :status, null: false, default: "pending"   # pending, approved, rejected
      t.string :staff_reason
      t.references :reviewed_by, foreign_key: { to_table: :accounts }
      t.datetime :reviewed_at
      t.references :spell, foreign_key: { to_table: :grimoire_spells, on_delete: :nullify }
      t.timestamps
    end
  end
end
