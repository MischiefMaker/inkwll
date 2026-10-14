# How often a player wants email about new activity. "off" until they opt in.
class AddEmailNotificationsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :email_notifications, :string, null: false, default: "off"
  end
end
