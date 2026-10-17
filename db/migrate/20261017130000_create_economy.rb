# Version 2.0, Theme 9: the Economy (docs/economy.md). One kind of money.
# Characters have a Purse and factions a Bank, both economy_accounts. Every
# change is a line on a ledger (economy_entries), so a balance can always be
# traced. Scheduled payments, faction taxes and dues, and the weekly
# allowance move money on their own.
class CreateEconomy < ActiveRecord::Migration[8.1]
  def change
    create_table :economy_accounts do |t|
      t.references :owner, polymorphic: true, null: false, index: { unique: true }
      t.integer :balance, null: false, default: 0
      t.timestamps
    end

    create_table :economy_schedules do |t|
      # No payer means the game pays: money staff create, such as a stipend.
      t.references :from_account, foreign_key: { to_table: :economy_accounts, on_delete: :cascade }
      t.references :to_account, null: false, foreign_key: { to_table: :economy_accounts, on_delete: :cascade }
      t.integer :amount, null: false
      t.string :interval, null: false, default: "week"
      t.date :next_due_on, null: false
      t.date :ends_on
      t.string :note
      t.references :created_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.references :created_by_character, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.datetime :stopped_at
      t.string :stopped_reason
      t.timestamps
    end

    create_table :economy_entries do |t|
      t.references :account, null: false, foreign_key: { to_table: :economy_accounts, on_delete: :cascade }
      # The other side of a payment, when there is one.
      t.references :counterparty, foreign_key: { to_table: :economy_accounts, on_delete: :nullify }
      t.integer :amount, null: false
      t.integer :balance_after, null: false
      t.string :kind, null: false
      t.string :note
      # Who did it: the account, and for Bank actions the manager's character.
      t.references :actor, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.references :actor_character, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.references :schedule, foreign_key: { to_table: :economy_schedules, on_delete: :nullify }
      # Stops the same automatic payment going through twice.
      t.string :key
      t.datetime :created_at, null: false
      t.index :key, unique: true, where: "key IS NOT NULL"
      t.index %i[ account_id created_at ]
    end

    # Boons and Banes staff mark as changing the weekly allowance, such as
    # "Wealthy" (+10) or "Penniless" (-5). Kept here so SOUL's own tables
    # don't change.
    create_table :economy_allowance_changes do |t|
      t.references :soul_bnb, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.integer :amount, null: false
      t.timestamps
    end

    change_table :game_settings, bulk: true do |t|
      t.boolean :economy_enabled, null: false, default: false
      t.boolean :economy_taxes_enabled, null: false, default: false
      t.string :currency_one, null: false, default: "crown"
      t.string :currency_other, null: false, default: "crowns"
      t.string :currency_symbol
      t.integer :economy_starting_amount, null: false, default: 0
      t.integer :economy_allowance, null: false, default: 0
      t.integer :economy_tax_max_percent, null: false, default: 25
      t.integer :economy_dues_max, null: false, default: 0
    end

    change_table :factions, bulk: true do |t|
      t.integer :income_tax_percent, null: false, default: 0
      t.integer :dues_amount, null: false, default: 0
      t.string :dues_interval, null: false, default: "month"
      t.date :dues_next_on
    end

    add_column :faction_memberships, :bank_manager, :boolean, null: false, default: false
    # What a money alert says ("Sable paid Wren 5 crowns.").
    add_column :alerts, :note, :string
  end
end
