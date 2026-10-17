# Version 2.0, Theme 4: factions. Families, guilds, clubs and other circles a
# character can belong to many of, unlike a character group (one each).
# A faction can be secret, and so can one membership. Heads can add members;
# staff run a faction whose heads are NPCs or on the roster.
# Faction Banks (Economy) will hang off factions and memberships later.
class CreateFactions < ActiveRecord::Migration[8.1]
  def change
    create_table :factions do |t|
      t.string :name, null: false
      t.text :description
      # Heads who are NPCs, by name. Staff run the faction for them.
      t.string :npc_heads
      t.boolean :secret, null: false, default: false
      t.boolean :pick_on_application, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
      t.index "lower(name)", unique: true
    end

    create_table :faction_memberships do |t|
      t.references :faction, null: false, foreign_key: { on_delete: :cascade }
      t.references :character, null: false, foreign_key: { on_delete: :cascade }
      t.string :title
      t.boolean :head, null: false, default: false
      t.boolean :secret, null: false, default: false
      t.timestamps
      t.index %i[ faction_id character_id ], unique: true
    end

    add_column :inklings, :shared_faction_ids, :integer, array: true, null: false, default: []
    add_column :game_settings, :factions_enabled, :boolean, null: false, default: false
  end
end
