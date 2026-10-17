# A live chat tab marking its conversation read while the player is looking at it.
class Conversations::ReadingsController < ApplicationController
  def update
    member = Conversation.find(params[:conversation_id]).member_for(current_account) or raise ActiveRecord::RecordNotFound
    member.mark_read!
    head :no_content
  end
end
