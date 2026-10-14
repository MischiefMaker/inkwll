# Someone who keeps hitting the posting limits is muted for a short while.
class AddMutedUntilToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :muted_until, :datetime
  end
end
