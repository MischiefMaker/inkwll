# Messages: a player's out-of-character conversations with other players.
class ConversationsController < ApplicationController
  limit_posting to: 10, only: :create, name: "new_conversations"
  before_action :set_conversation, only: :show

  def index
    @members = current_account.conversation_members.active.includes(conversation: { members: %i[ account via_character ] })
      .joins(:conversation).merge(Conversation.by_activity)
  end

  # ?to=Robin or ?character_id=5 ("message the player of" a character).
  def new
    @to = params[:to].presence || Character.find_by(id: params[:character_id])&.name
  end

  def create
    @to = params[:to]
    recipients = Conversation.resolve(@to, from: current_account)
    @conversation = Conversation.start!(from: current_account, recipients: recipients, subject: params[:subject], body: params[:body])
    redirect_to @conversation
  rescue Conversation::UnknownName, ActiveRecord::RecordInvalid, ArgumentError => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def show
    @member.mark_read!
  end

  private
    # Only people in a conversation can read it.
    def set_conversation
      @conversation = Conversation.find(params[:id])
      @member = @conversation.member_for(current_account) or raise ActiveRecord::RecordNotFound
    end
end
