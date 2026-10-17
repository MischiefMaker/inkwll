# Version 2.0: Passages meant for some characters only. A Mutter is whispered
# to one character: they see it all, everyone else only the overheard version
# with most words turned into "...". to_character_ids says who it's for.
class AddRecipientsToPoses < ActiveRecord::Migration[8.1]
  def change
    add_column :poses, :to_character_ids, :bigint, array: true, null: false, default: []
    add_column :poses, :overheard_body, :text
  end
end
