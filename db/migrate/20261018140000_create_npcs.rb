# Version 2.0: NPCs. Staff make recurring non-player characters in the admin
# panel (name, picture, a public description, private notes and SOUL ratings),
# and whoever runs a Chapter can pick one for an NPC Passage instead of typing
# its name. NPCs never show in any player's characters.
class CreateNpcs < ActiveRecord::Migration[8.1]
  def change
    create_table :npcs do |t|
      t.string :name, null: false
      t.text :description
      t.text :notes
      t.jsonb :soul_ratings, null: false, default: {}
      t.timestamps
    end
    add_index :npcs, "lower(name)", unique: true
    add_reference :poses, :npc, foreign_key: { on_delete: :nullify }
  end
end
