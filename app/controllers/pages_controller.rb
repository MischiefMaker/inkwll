# Pages: a quick private message to one player (or the player of a character)
# from the chat sidebar. It opens as a live chat tab for both of them.
class PagesController < ApplicationController
  limit_posting to: 20

  def create
    recipients = Conversation.resolve(params[:to], from: current_account)
    raise Conversation::UnknownName, "Page one player at a time." if recipients.size > 1
    raise Conversation::UnknownName, "Who would you like to page?" if recipients.empty?
    conversation = Conversation.page!(from: current_account, to: recipients.first, body: params[:body])
    render turbo_stream: turbo_stream.replace("private-chats", partial: "private_chats/panel",
      locals: { account: current_account, open: "chat-#{conversation.id}" })
  rescue Conversation::UnknownName, ActiveRecord::RecordInvalid, ArgumentError => e
    render turbo_stream: turbo_stream.replace("private-chats", partial: "private_chats/panel",
      locals: { account: current_account, open: "page", problem: e.message }), status: :unprocessable_entity
  end
end
