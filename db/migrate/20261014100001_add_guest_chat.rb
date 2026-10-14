class AddGuestChat < ActiveRecord::Migration[8.1]
  def change
    change_column_null :ooc_messages, :account_id, true
    add_column :ooc_messages, :guest_name, :string
    add_column :ooc_messages, :ip_address, :inet
    add_column :game_settings, :guest_chat, :boolean, default: true, null: false
  end
end
