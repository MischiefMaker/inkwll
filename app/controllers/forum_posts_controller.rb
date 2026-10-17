# Replies in a forum thread. Each board says who may reply; a locked thread
# takes no replies except from moderators. Writers can edit their own posts.
# Moderators (Scribes and Wellkeepers) can edit or delete any reply.
class ForumPostsController < ApplicationController
  limit_posting to: 10, within: 5.minutes, only: :create
  before_action :set_topic
  before_action :set_post, only: %i[ edit update destroy ]
  before_action :require_editor, only: %i[ edit update ]

  def create
    unless @topic.may_reply?(current_account)
      return redirect_to forum_topic_path(@topic), alert: "You can't reply in this thread."
    end
    @reply = @topic.posts.new(account: current_account, body: params.dig(:forum_post, :body))
    if @topic.board.in_character?
      @reply.character = @topic.board.characters_for(current_account).find { |character| character.id == params.dig(:forum_post, :character_id).to_i }
      return redirect_to forum_topic_path(@topic, page: "last"), alert: "Choose which of your characters to post as." unless @reply.character
    end
    if @reply.save
      redirect_to forum_topic_path(@topic, page: "last", anchor: helpers.dom_id(@reply))
    else
      redirect_to forum_topic_path(@topic, page: "last"), alert: "Your reply #{@reply.errors.full_messages.to_sentence.downcase}."
    end
  end

  def edit
  end

  def update
    if @post.update(body: params.dig(:forum_post, :body), edited_at: Time.current)
      redirect_to forum_topic_path(@topic, anchor: helpers.dom_id(@post)), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # The opening post goes with its thread, so it's deleted by deleting the thread.
  def destroy
    unless ForumTopic.moderator?(current_account)
      return redirect_to forum_topic_path(@topic), alert: "Only Scribes and Wellkeepers can delete posts."
    end
    if @post.opening?
      return redirect_to forum_topic_path(@topic), alert: "That's the thread's opening post. Delete the whole thread instead."
    end
    @post.destroy!
    redirect_to forum_topic_path(@topic), notice: "Post deleted."
  end

  private
    def set_topic
      @topic = ForumTopic.find(params[:forum_topic_id])
    end

    def set_post
      @post = @topic.posts.find(params[:id])
    end

    def require_editor
      redirect_to forum_topic_path(@topic), alert: "You can only edit your own posts." unless @post.editable_by?(current_account)
    end
end
