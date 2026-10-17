# Version 2.0: "The story so far". A short summary any player in a Chapter can
# edit, pinned at its top, and shown cut to one line in the Place's list of
# Chapters and on the Bookshelf.
class AddSummaryToScenes < ActiveRecord::Migration[8.1]
  def change
    add_column :scenes, :summary, :text
    add_reference :scenes, :summary_by, foreign_key: { to_table: :characters }
    add_column :scenes, :summary_at, :datetime
  end
end
