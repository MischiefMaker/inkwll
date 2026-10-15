# SOUL basics: Aspects and Skills (set by staff), each character's ratings
# and Resonance, the XP ledger, and rolls made in Chapters.
class CreateSoul < ActiveRecord::Migration[8.1]
  ASPECTS = [
    [ "body", "Body", "Physical capability and endurance", [ %w[ strength Strength ], %w[ speed Speed ], %w[ stamina Stamina ] ] ],
    [ "mind", "Mind", "Intellect, perception, and reason", [ %w[ intelligence Intelligence ], %w[ learning Learning ], %w[ wit Wit ] ] ],
    [ "spirit", "Spirit", "Willpower, emotional depth, and the arcane", [ [ "ceremonial", "Ceremonial Magic" ], %w[ hedgecraft Hedgecraft ], [ "natural", "Natural Magic" ] ] ]
  ].freeze

  def change
    create_table :soul_aspects do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.string :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :soul_aspects, :key, unique: true

    create_table :soul_skills do |t|
      t.references :soul_aspect, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.string :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :soul_skills, :key, unique: true

    create_table :soul_ratings do |t|
      t.references :character, null: false, foreign_key: true
      t.references :trait, polymorphic: true, null: false
      t.integer :rating, null: false, default: 0
      t.timestamps
    end
    add_index :soul_ratings, %i[ character_id trait_type trait_id ], unique: true

    create_table :soul_xp_entries do |t|
      t.references :character, null: false, foreign_key: true
      t.string :kind, null: false             # award, spend, correction
      t.string :source                        # weekly, scene, staff
      t.integer :amount, null: false          # + for awards, - for spending
      t.integer :catchup_amount, null: false, default: 0
      t.string :note
      t.string :idempotency_key
      t.references :actor, foreign_key: { to_table: :accounts }
      t.references :trait, polymorphic: true
      t.integer :new_rating
      t.timestamps
    end
    add_index :soul_xp_entries, :idempotency_key, unique: true

    create_table :soul_rolls do |t|
      t.references :character, null: false, foreign_key: true
      t.references :scene, foreign_key: true
      t.references :pose, foreign_key: true
      t.references :soul_skill, foreign_key: { on_delete: :nullify }
      t.string :skill_name, null: false
      t.string :difficulty_name, null: false
      t.integer :difficulty, null: false
      t.integer :skill_rating, null: false
      t.integer :aspect_bonus, null: false
      t.jsonb :dice, null: false, default: {}
      t.integer :result, null: false
      t.string :degree, null: false
      t.float :probability
      t.boolean :extraordinary, null: false, default: false
      t.timestamps
    end

    add_column :characters, :resonance, :integer, null: false, default: 0
    add_column :characters, :sheet_locked_at, :datetime
    add_column :game_settings, :soul_enabled, :boolean, null: false, default: true

    reversible do |dir|
      dir.up do
        now = Time.current
        ASPECTS.each_with_index do |(key, name, description, skills), index|
          aspect_id = insert_row(:soul_aspects, key: key, name: name, description: description, position: index + 1, created_at: now, updated_at: now)
          skills.each_with_index do |(skill_key, skill_name), position|
            insert_row(:soul_skills, soul_aspect_id: aspect_id, key: skill_key, name: skill_name, position: position + 1, created_at: now, updated_at: now)
          end
        end
      end
    end
  end

  private
    def insert_row(table, **values)
      columns = values.keys.join(", ")
      quoted = values.values.map { |value| connection.quote(value) }.join(", ")
      select_value("INSERT INTO #{table} (#{columns}) VALUES (#{quoted}) RETURNING id")
    end
end
