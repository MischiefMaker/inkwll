class CreateProfiles < ActiveRecord::Migration[8.1]
  def up
    # The game's in-character date: on ic_anchor_at (real time) it was
    # ic_anchor_date in the game, and game time runs ic_days_per_day times
    # as fast as real time.
    add_column :game_settings, :ic_anchor_at, :datetime
    add_column :game_settings, :ic_anchor_date, :date
    add_column :game_settings, :ic_days_per_day, :decimal, precision: 6, scale: 2, default: 1, null: false
    add_column :game_settings, :require_description, :boolean, default: false, null: false
    add_column :game_settings, :require_icon, :boolean, default: false, null: false

    # Profile and application fields, set up by each game.
    create_table :profile_fields do |t|
      t.string :name, null: false
      t.string :section, null: false, default: "demographics"
      t.string :field_type, null: false, default: "text"
      t.boolean :public, null: false, default: true
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0
      t.string :hint
      t.timestamps
    end

    create_table :profile_values do |t|
      t.references :character, null: false, foreign_key: true
      t.references :profile_field, null: false, foreign_key: true
      t.text :value
      t.timestamps
    end
    add_index :profile_values, %i[ character_id profile_field_id ], unique: true

    create_table :gallery_images do |t|
      t.references :character, null: false, foreign_key: true
      t.string :caption
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :relationships do |t|
      t.references :character, null: false, foreign_key: true
      t.references :other_character, foreign_key: { to_table: :characters }
      t.string :other_name
      t.string :kind, null: false, default: "friend"
      t.text :note
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    # Applications: draft, submitted, approved or returned (with a note).
    add_column :characters, :status, :string, null: false, default: "draft"
    add_column :characters, :submitted_at, :datetime
    add_column :characters, :reviewed_at, :datetime
    add_reference :characters, :reviewed_by, foreign_key: { to_table: :accounts }
    add_column :characters, :review_note, :text
    execute "UPDATE characters SET status = 'approved'"

    add_column :accounts, :about_me, :text

    # The default fields. Each game can change them.
    now = Time.current.to_fs(:db)
    [
      [ "Birthday", "demographics", "birthday", true, 1, "Their age is worked out from this, using the game's date." ],
      [ "Hometown", "demographics", "text", true, 2, nil ],
      [ "Occupation", "demographics", "text", true, 3, nil ],
      [ "Background", "application", "long_text", true, 1, "Where they came from and what shaped them." ],
      [ "Personality", "application", "long_text", true, 2, nil ]
    ].each do |name, section, type, is_public, position, hint|
      execute ActiveRecord::Base.sanitize_sql([
        "INSERT INTO profile_fields (name, section, field_type, public, required, position, hint, created_at, updated_at) VALUES (?, ?, ?, ?, false, ?, ?, ?, ?)",
        name, section, type, is_public, position, hint, now, now
      ])
    end
  end

  def down
    remove_column :accounts, :about_me
    remove_column :characters, :review_note
    remove_reference :characters, :reviewed_by
    remove_column :characters, :reviewed_at
    remove_column :characters, :submitted_at
    remove_column :characters, :status
    drop_table :relationships
    drop_table :gallery_images
    drop_table :profile_values
    drop_table :profile_fields
    remove_column :game_settings, :require_icon
    remove_column :game_settings, :require_description
    remove_column :game_settings, :ic_days_per_day
    remove_column :game_settings, :ic_anchor_date
    remove_column :game_settings, :ic_anchor_at
  end
end
