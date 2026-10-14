# Apartment-style Settings: a Setting can be a special type (an apartment
# building, a hotel...) and its Paths can carry a door number, shown as a
# compact numbered list ("100 - Jaxon Marley").
class AddNumberedPaths < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :kind, :string, null: false, default: "plain"
    add_column :exits, :number, :string
    add_index :exits, %i[ source_room_id number ], unique: true, where: "number IS NOT NULL"
  end
end
