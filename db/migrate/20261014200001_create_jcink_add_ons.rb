# Step 6c, borrowed from Jcink boards: profile fields shown beside Passages,
# Chapter subtitles and labels, character groups that colour names, and
# the alerts bell.
class CreateJcinkAddOns < ActiveRecord::Migration[8.1]
  def change
    add_column :profile_fields, :on_passages, :boolean, null: false, default: false

    add_column :scenes, :subtitle, :string
    add_column :scenes, :label_ids, :integer, array: true, null: false, default: []
    create_table :scene_labels do |t|
      t.string :name, null: false
      t.string :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :character_groups do |t|
      t.string :name, null: false
      t.string :colour, null: false, default: "#5b3f8c"
      t.string :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_reference :characters, :character_group, foreign_key: { on_delete: :nullify }

    # kind: passage, turn, mention or finished. New Passages in one Chapter
    # add to one unread alert instead of making a new one each time.
    create_table :alerts do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.references :character, foreign_key: { on_delete: :cascade }
      t.references :scene, foreign_key: { on_delete: :cascade }
      t.references :pose, foreign_key: { on_delete: :nullify }
      t.string :kind, null: false
      t.integer :count, null: false, default: 1
      t.datetime :read_at
      t.timestamps
    end
    add_index :alerts, %i[ account_id read_at ]
  end
end
