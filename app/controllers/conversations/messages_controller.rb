# Replying in a Messages conversation.
class Conversations::MessagesController < ApplicationController
  limit_posting to: 20

  def create
    conversation = Conversation.find(params[:conversation_id])
    raise ActiveRecord::RecordNotFound unless conversation.member_for(current_account)

    conversation.post!(current_account, params.expect(message: [ :body ])[:body])
    redirect_to conversation_path(conversation, anchor: "reply")
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to conversation_path(conversation), alert: e.message
  end
end
