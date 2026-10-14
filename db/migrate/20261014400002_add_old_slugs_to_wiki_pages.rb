# Addresses a wiki page had before it was renamed, so old links still find it.
class AddOldSlugsToWikiPages < ActiveRecord::Migration[8.1]
  def change
    add_column :wiki_pages, :old_slugs, :string, array: true, default: [], null: false
    add_index :wiki_pages, :old_slugs, using: :gin
  end
end
