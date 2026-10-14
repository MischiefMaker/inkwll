# Scenes (shown to players as Chapters), the characters in them, their poses
# (Passages) and invitations to private or hidden scenes.
class CreateScenes < ActiveRecord::Migration[8.1]
  def change
    create_table :scenes do |t|
      t.references :room, null: false, foreign_key: true
      t.string :title, null: false
      t.string :visibility, null: false, default: "joinable"
      t.string :pose_mode, null: false, default: "turns"
      t.boolean :auto_skip, null: false, default: true
      t.integer :turn_minutes, null: false, default: 5
      t.bigint :current_turn_participant_id
      t.datetime :turn_started_at
      t.datetime :turn_warned_at
      t.integer :turn_token, null: false, default: 0
      t.integer :last_sequence, null: false, default: 0
      t.datetime :last_pose_at
      t.timestamps
    end
    add_index :scenes, :last_pose_at

    create_table :scene_participants do |t|
      t.references :scene, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.string :role, null: false, default: "player"
      t.integer :position, null: false
      t.integer :last_read_sequence, null: false, default: 0
      t.timestamps
    end
    add_index :scene_participants, %i[ scene_id character_id ], unique: true
    add_foreign_key :scenes, :scene_participants, column: :current_turn_participant_id, on_delete: :nullify

    create_table :scene_invitations do |t|
      t.references :scene, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.timestamps
    end
    add_index :scene_invitations, %i[ scene_id character_id ], unique: true

    create_table :poses do |t|
      t.references :scene, null: false, foreign_key: true
      t.references :character, foreign_key: true
      t.string :kind, null: false, default: "passage"
      t.text :body, null: false
      t.text :original_body
      t.integer :sequence, null: false
      t.datetime :edited_at
      t.datetime :removed_at
      t.timestamps
    end
    add_index :poses, %i[ scene_id sequence ], unique: true

    change_table :game_settings do |t|
      t.boolean :auto_skip, null: false, default: true
      t.integer :turn_minutes, null: false, default: 5
    end
  end
end
