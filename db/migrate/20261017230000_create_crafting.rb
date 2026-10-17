# Version 2.0, Theme 9: items and Crafting (docs/crafting.md). Items,
# Belongings, the staff catalogue, shops in Places, Give and Trade come
# with the Economy; making items, features and the Market need Crafting
# switched on too.
class CreateCrafting < ActiveRecord::Migration[8.1]
  def change
    # What can be made: a sword (40 crowns, Smithing).
    create_table :crafting_item_types do |t|
      t.string :name, null: false
      t.text :description
      t.integer :base_cost, null: false, default: 0
      t.references :soul_skill, foreign_key: { on_delete: :nullify }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    # What an item can do for rolls: like a SOUL Boon tied to some Skills.
    create_table :crafting_features do |t|
      t.string :name, null: false
      t.text :description
      t.string :level, null: false, default: "minor"
      t.integer :skill_ids, array: true, null: false, default: []
      # Empty means it fits every item type.
      t.integer :item_type_ids, array: true, null: false, default: []
      # Players propose features; staff approve or decline them.
      t.string :status, null: false, default: "approved"
      t.references :proposed_by, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.string :decline_reason
      t.timestamps
    end

    # Ready-made items staff sell in shops and give as rewards.
    create_table :crafting_catalogue_items do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price, null: false, default: 0
      t.integer :feature_ids, array: true, null: false, default: []
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    # A Place's shop: the catalogue items sold there.
    create_table :crafting_shop_listings do |t|
      t.references :room, null: false, foreign_key: { on_delete: :cascade }
      t.references :catalogue_item, null: false, foreign_key: { to_table: :crafting_catalogue_items, on_delete: :cascade }
      t.timestamps
      t.index %i[ room_id catalogue_item_id ], unique: true
    end

    # Something a character owns. Stacks (12 arrows) have a quantity.
    create_table :crafting_items do |t|
      t.references :character, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.text :description
      t.integer :quantity, null: false, default: 1
      t.references :catalogue_item, foreign_key: { to_table: :crafting_catalogue_items, on_delete: :nullify }
      t.references :item_type, foreign_key: { to_table: :crafting_item_types, on_delete: :nullify }
      t.integer :feature_ids, array: true, null: false, default: []
      # The maker's mark: kept by name too, so it survives the maker.
      t.references :maker, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.string :maker_name
      t.datetime :made_at
      t.boolean :masterwork, null: false, default: false
      # A Minor flaw from a complicated success: a Bane on some Skills.
      t.string :flaw_name
      t.integer :flaw_skill_ids, array: true, null: false, default: []
      # On the Market when it has a price.
      t.integer :price
      t.datetime :listed_at
      t.timestamps
      t.index :listed_at
    end

    # Everything that happens to an item, like a ledger.
    create_table :crafting_item_events do |t|
      t.references :item, foreign_key: { to_table: :crafting_items, on_delete: :nullify }
      t.string :item_name, null: false
      t.integer :quantity, null: false, default: 1
      t.references :character, foreign_key: { on_delete: :nullify }
      t.references :other_character, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.string :kind, null: false
      t.string :note
      t.references :actor, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.datetime :created_at, null: false
    end

    # An offer between two characters: money and items each way. It goes
    # through once both have agreed to the same offer.
    create_table :crafting_trades do |t|
      t.references :from_character, null: false, foreign_key: { to_table: :characters, on_delete: :cascade }
      t.references :to_character, null: false, foreign_key: { to_table: :characters, on_delete: :cascade }
      t.integer :from_money, null: false, default: 0
      t.integer :to_money, null: false, default: 0
      t.boolean :from_agreed, null: false, default: false
      t.boolean :to_agreed, null: false, default: false
      t.string :status, null: false, default: "open"
      t.references :scene, foreign_key: { on_delete: :nullify }
      t.timestamps
    end

    create_table :crafting_trade_items do |t|
      t.references :trade, null: false, foreign_key: { to_table: :crafting_trades, on_delete: :cascade }
      t.references :item, null: false, foreign_key: { to_table: :crafting_items, on_delete: :cascade }
      t.integer :quantity, null: false, default: 1
      t.timestamps
      t.index %i[ trade_id item_id ], unique: true
    end

    change_table :game_settings, bulk: true do |t|
      t.boolean :crafting_enabled, null: false, default: false
      # 0 means no limit.
      t.integer :crafting_max_features, null: false, default: 3
      t.string :crafting_highest_level, null: false, default: "major"
      t.integer :crafting_minor_cost, null: false, default: 200
      t.integer :crafting_major_cost, null: false, default: 600
      t.integer :crafting_legendary_cost, null: false, default: 2000
    end

    # Item features a Storyteller rules on when judging a roll, kept apart
    # from the Boons and Banes ids because they come from other systems.
    change_table :soul_pending_rolls, bulk: true do |t|
      t.string :mandatory_extra_keys, array: true, null: false, default: []
      t.string :optional_extra_keys, array: true, null: false, default: []
    end
  end
end
