# Version 2.0: an "Away until (date)" notice a player sets on their profile.
# It shows on their Chapters beside whose turn it is, and stops showing once
# the date has passed.
class AddAwayToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :away_until, :date
    add_column :accounts, :away_note, :string
  end
end
