# Sending a message from a live chat tab in the chat sidebar. It arrives live
# for everyone in the conversation, opening the tab for them if it was closed.
class Conversations::LiveMessagesController < ApplicationController
  limit_posting to: 30

  def create
    conversation = Conversation.find(params[:conversation_id])
    raise ActiveRecord::RecordNotFound unless conversation.member_for(current_account)
    conversation.post!(current_account, params.expect(message: [ :body ])[:body], live: true)
    head :no_content
  rescue ArgumentError, ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end
end
