# Version 2.0, Theme 9: Domains (docs/economy.md, "Domains"). Pieces of land
# in a chain of lieges (a Barony under a County under a Duchy), each with a
# number of people who bring in money every month. Each Domain pays tax to
# its liege, and the rest goes to its holder's Purse or Bank.
class CreateDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :domains do |t|
      t.string :name, null: false
      # A word staff choose, such as Realm, Duchy, County or Barony.
      t.string :rank
      t.text :description
      t.references :liege, foreign_key: { to_table: :domains, on_delete: :nullify }
      t.references :holder_character, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.references :holder_faction, foreign_key: { to_table: :factions, on_delete: :nullify }
      t.references :area, foreign_key: { on_delete: :nullify }
      t.integer :people, null: false, default: 0
      t.integer :yield_per_head, null: false, default: 0
      # The share of its income it pays its liege, set by the liege's holder.
      t.integer :tax_percent, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.timestamps
      t.index "lower(name)", unique: true
    end

    change_table :game_settings, bulk: true do |t|
      t.boolean :domains_enabled, null: false, default: false
      t.integer :domain_tax_max_percent, null: false, default: 50
    end
  end
end
