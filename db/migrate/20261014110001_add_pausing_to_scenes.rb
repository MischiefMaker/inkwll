class AddPausingToScenes < ActiveRecord::Migration[8.1]
  def change
    add_column :scenes, :paused_at, :datetime
    add_column :scenes, :pause_note, :string
  end
end
