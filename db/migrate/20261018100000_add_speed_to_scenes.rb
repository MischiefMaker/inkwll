# Version 2.0: the Chapter speed toggle. "live" shows the Chapter as a chat
# (Enter posts, a small box), "forum" as forum posts (a big box for long
# Passages). Empty means the game's usual look from Admin → Look.
class AddSpeedToScenes < ActiveRecord::Migration[8.1]
  def change
    add_column :scenes, :speed, :string
  end
end
