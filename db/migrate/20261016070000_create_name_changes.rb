class CreateNameChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :name_changes do |t|
      t.string :subject_type, null: false
      t.bigint :subject_id, null: false
      t.string :old_name, null: false
      t.string :new_name, null: false
      t.references :changed_by, foreign_key: { to_table: :accounts, on_delete: :nullify }, null: true
      t.timestamps
    end
    add_index :name_changes, %i[ subject_type subject_id ]
    add_index :name_changes, :created_at
  end
end
