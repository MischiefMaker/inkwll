# Group pages: each character group gets a list of ranks set by its leaders,
# a rank and leader tick on each character, and its own in-character board.
class AddGroupPages < ActiveRecord::Migration[8.0]
  def change
    add_column :character_groups, :ranks, :text
    add_column :characters, :group_rank, :string
    add_column :characters, :group_leader, :boolean, default: false, null: false
    add_reference :forum_boards, :character_group, foreign_key: { on_delete: :cascade }, index: { unique: true }
  end
end
