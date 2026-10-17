# Opening a Messages conversation as a live chat tab in the chat sidebar, and
# closing the tab (the conversation stays in Messages).
class Conversations::LiveTabsController < ApplicationController
  before_action :set_member

  def create
    @member.conversation.open_live!(only: current_account)
    redirect_to conversation_path(@member.conversation), notice: "Open in the chat sidebar."
  end

  def destroy
    @member.update!(live_open: false)
    current_account.broadcast_private_chats
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("private-chats", partial: "private_chats/panel", locals: { account: current_account }) }
      format.html { redirect_back fallback_location: conversation_path(@member.conversation) }
    end
  end

  private
    def set_member
      @member = Conversation.find(params[:conversation_id]).member_for(current_account) or raise ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound unless @member.active?
    end
end
