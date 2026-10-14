# Storytellers suggest XP awards for the players in their Chapters; staff
# approve them (owner, 2026-10-14).
class CreateSoulAwardSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :soul_award_suggestions do |t|
      t.references :character, null: false, foreign_key: true
      t.references :scene, null: false, foreign_key: true
      t.references :suggested_by, null: false, foreign_key: { to_table: :accounts }
      t.integer :amount, null: false
      t.text :reason, null: false
      t.string :status, null: false, default: "pending"
      t.string :staff_reason
      t.references :reviewed_by, foreign_key: { to_table: :accounts }
      t.datetime :reviewed_at
      t.timestamps
    end
  end
end
