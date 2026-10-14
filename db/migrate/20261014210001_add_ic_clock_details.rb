# Step 7, the rest of game time: each Chapter keeps its own date (and an
# optional time of day), and staff can describe today's weather.
class AddIcClockDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :scenes, :ic_date, :date
    add_column :scenes, :ic_time, :string
    add_column :game_settings, :weather, :string
  end
end
