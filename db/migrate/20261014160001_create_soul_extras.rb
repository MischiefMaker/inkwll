# SOUL extras: Boons and Banes (a catalogue, each character's, and requests
# for new ones), rolls the Storyteller helps with, Culminations, the
# player-facing Narrative History and the staff-only audit trail.
class CreateSoulExtras < ActiveRecord::Migration[8.1]
  def change
    create_table :soul_bnbs do |t|
      t.string :kind, null: false                       # boon or bane
      t.string :name, null: false
      t.text :description
      t.integer :skill_ids, array: true, null: false, default: []
      t.boolean :starting, null: false, default: true   # can be picked on a starting sheet
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :soul_character_bnbs do |t|
      t.references :character, null: false, foreign_key: true
      t.references :soul_bnb, null: false, foreign_key: true
      t.string :level, null: false, default: "minor"
      t.integer :skill_ids, array: true, null: false, default: []
      t.text :explanation
      t.string :source, null: false                     # starting, staff, request
      t.datetime :resolved_at
      t.timestamps
    end

    create_table :soul_bnb_requests do |t|
      t.references :character, null: false, foreign_key: true
      t.references :soul_bnb, null: false, foreign_key: true
      t.string :level, null: false, default: "minor"
      t.integer :skill_ids, array: true, null: false, default: []
      t.text :explanation
      t.string :status, null: false, default: "pending"
      t.string :staff_reason
      t.references :reviewed_by, foreign_key: { to_table: :accounts }
      t.datetime :reviewed_at
      t.timestamps
    end

    create_table :soul_pending_rolls do |t|
      t.references :character, null: false, foreign_key: true
      t.references :scene, null: false, foreign_key: true
      t.references :soul_skill, null: false, foreign_key: true
      t.string :difficulty_name, null: false
      t.string :status, null: false, default: "waiting"   # waiting, rolled, cancelled
      t.timestamps
    end

    create_table :soul_culminations do |t|
      t.references :character, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "proposed"  # proposed, approved, denied, revoked
      t.string :staff_reason
      t.references :reviewed_by, foreign_key: { to_table: :accounts }
      t.datetime :reviewed_at
      t.timestamps
    end

    create_table :soul_history_entries do |t|
      t.references :character, null: false, foreign_key: true
      t.string :event, null: false
      t.string :narrative, null: false
      t.timestamps
    end

    create_table :soul_audit_entries do |t|
      t.references :character, foreign_key: { on_delete: :nullify }
      t.references :actor, foreign_key: { to_table: :accounts }
      t.string :action, null: false
      t.string :summary, null: false
      t.string :reason
      t.timestamps
    end

    add_column :soul_rolls, :net_modifier, :integer, null: false, default: 0
    add_column :soul_rolls, :applied, :jsonb, null: false, default: []
    add_reference :soul_rolls, :storyteller, foreign_key: { to_table: :characters, on_delete: :nullify }
  end
end
