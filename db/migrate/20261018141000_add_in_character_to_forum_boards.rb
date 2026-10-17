# Version 2.0: IC or OOC boards. An in-character board has people post as one
# of their characters instead of under their player name.
class AddInCharacterToForumBoards < ActiveRecord::Migration[8.1]
  def change
    add_column :forum_boards, :in_character, :boolean, default: false, null: false
    add_reference :forum_topics, :character, foreign_key: { on_delete: :nullify }
    add_reference :forum_posts, :character, foreign_key: { on_delete: :nullify }
  end
end
