class CreateRememberedCharacters < ActiveRecord::Migration[8.1]
  def change
    # Remembers which character an account last used in a given place
    # (a room now, a scene later) so it can be switched back automatically.
    create_table :remembered_characters do |t|
      t.references :account, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: { on_delete: :cascade }
      t.references :context, null: false, polymorphic: true, index: false

      t.timestamps
    end
    add_index :remembered_characters, [ :account_id, :context_type, :context_id ], unique: true,
      name: "index_remembered_characters_on_account_and_context"
  end
end
