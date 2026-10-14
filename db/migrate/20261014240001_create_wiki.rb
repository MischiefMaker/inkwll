# Step 9b: the wiki. Any player can write pages in Markdown; every change is
# kept as a revision so it can be undone; staff can lock a page.
class CreateWiki < ActiveRecord::Migration[8.1]
  def change
    create_table :wiki_pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false, default: ""
      t.string :tags, array: true, null: false, default: []
      t.datetime :locked_at
      t.integer :menu_position     # set by staff to list the page in the Menu
      t.references :updated_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.timestamps
    end
    add_index :wiki_pages, :slug, unique: true
    add_index :wiki_pages, :tags, using: :gin

    create_table :wiki_revisions do |t|
      t.references :page, null: false, foreign_key: { to_table: :wiki_pages, on_delete: :cascade }
      t.references :account, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.text :body, null: false, default: ""
      t.string :summary
      t.timestamps
    end
  end
end
