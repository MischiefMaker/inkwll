class AddMyPlacesAndCharacterActivity < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_places do |t|
      t.references :account, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.timestamps
    end
    add_index :saved_places, %i[ account_id room_id ], unique: true

    add_column :characters, :last_active_at, :datetime
  end
end
