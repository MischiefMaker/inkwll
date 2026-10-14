class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :subject, null: false
      t.datetime :last_message_at
      t.timestamps
    end

    # Who's in a conversation. via_character is set when someone was added
    # as "the player of" a character: they're shown that way, so the
    # conversation doesn't reveal who plays the character.
    create_table :conversation_members do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :via_character, foreign_key: { to_table: :characters }
      t.datetime :last_read_at
      t.datetime :emailed_at
      t.datetime :left_at
      t.timestamps
    end
    add_index :conversation_members, %i[ conversation_id account_id ], unique: true

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :account, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    add_column :game_settings, :players_public, :boolean, default: false, null: false
  end
end
