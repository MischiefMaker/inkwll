# Step 8: Inklings, rebuilt from the owner's AresMUSH plugin. An Inkling is
# a thread about one character (a goal, a secret, a request to staff, a
# hint from staff) that the player builds up and sends to staff for review.
class CreateInklings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :inklings_enabled, :boolean, null: false, default: true

    create_table :inklings do |t|
      t.references :character, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :accounts }
      t.string :kind, null: false                       # a type from config/inklings.yml
      t.string :title, null: false
      t.string :status, null: false, default: "open"    # open, closed
      # The latest round of staff review: draft (staff can't see it yet),
      # submitted (locked, waiting for staff), needs_changes or approved.
      t.string :review_state, null: false, default: "draft"
      t.datetime :submitted_at          # the latest submission
      t.datetime :staff_visible_at      # first submitted, or made by staff
      t.integer :last_sequence, null: false, default: 0
      t.datetime :last_entry_at
      t.string :tags, array: true, null: false, default: []
      t.integer :shared_group_ids, array: true, null: false, default: []
      t.timestamps
    end
    add_index :inklings, :review_state

    create_table :inkling_shares do |t|
      t.references :inkling, null: false, foreign_key: { on_delete: :cascade }
      t.references :character, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
    add_index :inkling_shares, %i[ inkling_id character_id ], unique: true

    # kind: public (everyone with access), private (its writer, staff and
    # the character it's addressed to), gm (staff only), personal (only its
    # writer), roll, reward or system.
    create_table :inkling_entries do |t|
      t.references :inkling, null: false, foreign_key: { on_delete: :cascade }
      t.integer :sequence, null: false
      t.references :account, foreign_key: { on_delete: :nullify }
      t.references :character, foreign_key: { on_delete: :nullify }
      t.references :private_to, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.string :kind, null: false, default: "public"
      t.text :body, null: false
      t.boolean :private, null: false, default: false   # for rolls and rewards
      t.references :soul_roll, foreign_key: { on_delete: :nullify }
      t.timestamps
    end
    add_index :inkling_entries, %i[ inkling_id sequence ], unique: true

    create_table :inkling_reads do |t|
      t.references :inkling, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.integer :last_read_sequence, null: false, default: 0
      t.timestamps
    end
    add_index :inkling_reads, %i[ inkling_id account_id ], unique: true

    add_reference :alerts, :inkling, foreign_key: { on_delete: :cascade }
  end
end
