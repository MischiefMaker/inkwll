# Editing and deleting OOC Chat messages, and blocking people from the chat
# only (owner, 2026-10-15). Deleted messages stay as a "Deleted" or "Removed
# by staff" note; a chat-only ban stops someone posting there but leaves the
# rest of the game open to them.
class AddModerationToOocChat < ActiveRecord::Migration[8.1]
  def change
    change_table :ooc_messages do |t|
      t.datetime :edited_at
      t.boolean :edited_by_staff, null: false, default: false
      t.datetime :deleted_at
      t.references :removed_by, foreign_key: { to_table: :accounts, on_delete: :nullify }
    end
    add_column :bans, :chat_only, :boolean, null: false, default: false
  end
end
