class CreateOocMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :ooc_messages do |t|
      t.references :account, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
