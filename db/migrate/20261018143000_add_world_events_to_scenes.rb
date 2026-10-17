# The world timeline: staff mark finished Chapters as world events.
class AddWorldEventsToScenes < ActiveRecord::Migration[8.0]
  def change
    add_column :scenes, :world_event_at, :datetime
    add_column :scenes, :world_event_note, :string
    add_reference :scenes, :world_event_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
    add_index :scenes, :world_event_at
  end
end
