# Accounts now have one name: the player name people see is also the name
# they log in with (capitals ignored). Adds an email address and the game
# settings record that decides whether email is required.
class OnePlayerNameAndEmail < ActiveRecord::Migration[8.1]
  def up
    # The login name now always follows the player name.
    execute "UPDATE accounts SET username = LOWER(display_name)"

    add_column :accounts, :email, :string
    add_index :accounts, "LOWER(email)", unique: true, where: "email IS NOT NULL", name: "index_accounts_on_lower_email"

    create_table :game_settings do |t|
      t.boolean :email_required, null: false, default: true
      t.boolean :approval_required, null: false, default: true
      t.timestamps
    end
  end

  def down
    drop_table :game_settings
    remove_index :accounts, name: "index_accounts_on_lower_email"
    remove_column :accounts, :email
  end
end
