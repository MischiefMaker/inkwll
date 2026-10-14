class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters do |t|
      t.references :account, null: false, foreign_key: true
      # A character is always in exactly one room.
      t.references :room, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :characters, "lower(name)", unique: true, name: "index_characters_on_lower_name"

    add_reference :accounts, :active_character, foreign_key: { to_table: :characters, on_delete: :nullify }
  end
end
