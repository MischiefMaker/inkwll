class AddRosterRetiredAtToCharacters < ActiveRecord::Migration[8.1]
  def change
    add_column :characters, :roster_retired_at, :datetime
  end
end
