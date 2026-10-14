class CreateRoomsAndExits < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.text :description
      # New characters start in the room marked as the starting room.
      t.boolean :starting, null: false, default: false

      t.timestamps
    end

    # An exit is a one-way link from one room to another. Two-way passages
    # are two exits, one in each room.
    create_table :exits do |t|
      t.references :source_room, null: false, foreign_key: { to_table: :rooms }
      t.references :destination_room, null: false, foreign_key: { to_table: :rooms }
      t.string :name, null: false

      t.timestamps
    end
    add_index :exits, [ :source_room_id, :name ], unique: true
  end
end
