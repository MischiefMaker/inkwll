# Each Chapter gets a permanent number ("Chapter 12"), counted in the order
# Chapters were started. Existing Chapters are numbered oldest first.
class AddNumberToScenes < ActiveRecord::Migration[8.1]
  def up
    add_column :scenes, :number, :integer
    execute <<~SQL
      UPDATE scenes SET number = numbered.n
      FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) AS n FROM scenes) AS numbered
      WHERE scenes.id = numbered.id
    SQL
    change_column_null :scenes, :number, false
    add_index :scenes, :number, unique: true
  end

  def down
    remove_column :scenes, :number
  end
end
