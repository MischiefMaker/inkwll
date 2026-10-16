# Links an Inkling to a Chapter it started from or carried on in.
class CreateInklingSceneLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :inkling_scene_links do |t|
      t.references :inkling, null: false, foreign_key: true
      t.references :scene, null: false, foreign_key: true
      t.references :linked_by, null: false, foreign_key: { to_table: :accounts }
      t.timestamps
    end
    add_index :inkling_scene_links, %i[ inkling_id scene_id ], unique: true
  end
end
