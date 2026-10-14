# Leaving a Messages conversation. The others can still read what you wrote.
class Conversations::MembershipsController < ApplicationController
  def destroy
    member = Conversation.find(params[:conversation_id]).member_for(current_account) or raise ActiveRecord::RecordNotFound
    member.update!(left_at: Time.current)
    current_account.broadcast_message_count
    redirect_to conversations_path, notice: "You left the conversation."
  end
end
