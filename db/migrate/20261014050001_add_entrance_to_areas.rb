# Each Area has an entrance: the Setting you arrive at when you open the Area.
# From there players walk the Paths, so the grid feels like a real place.
class AddEntranceToAreas < ActiveRecord::Migration[8.1]
  def change
    add_reference :areas, :entrance_room, foreign_key: { to_table: :rooms, on_delete: :nullify }
  end
end
