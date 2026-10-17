# Version 2.0: live private chat. A Messages conversation can also be open as a
# tab in the chat sidebar, where its messages arrive live. Pages (quick direct
# messages) open it there for everyone in it.
class AddLiveOpenToConversationMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :conversation_members, :live_open, :boolean, default: false, null: false
  end
end
