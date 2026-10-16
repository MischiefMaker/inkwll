class AddSceneToInklingEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :inkling_entries, :scene, foreign_key: { on_delete: :nullify }, null: true
  end
end
