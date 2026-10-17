# Version 2.0: the "Looking for a scene" nudge. Remembers when a player last
# nudged everyone who's Looking for RP, so they can only do it every few hours.
class AddLfrpNudgedAtToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :lfrp_nudged_at, :datetime
  end
end
