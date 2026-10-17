# Threads on a forum board. Each board says who may start one. The thread's
# starter can change its title; moderators (Scribes and Wellkeepers) can also
# pin, lock and delete it.
class ForumTopicsController < ApplicationController
  allow_previews only: :show
  limit_posting to: 5, within: 10.minutes, only: :create
  before_action :set_board, only: %i[ new create ]
  before_action :require_starter, only: %i[ new create ]
  before_action :set_topic, only: %i[ show edit update destroy ]
  before_action :require_editor, only: %i[ edit update ]
  before_action :require_moderator, only: :destroy

  def new
    @topic = @board.topics.new
    @post = ForumPost.new
  end

  def create
    @topic = @board.topics.new(title: params.dig(:forum_topic, :title))
    @post = ForumPost.new(body: params.dig(:forum_topic, :body))
    @topic.validate
    @post.validate
    @post.errors.add(:base, "Choose which of your characters to post as.") if @board.in_character? && !posting_as
    @post.errors.delete(:topic)
    if @topic.errors.any? || @post.errors.any?
      render :new, status: :unprocessable_entity
    else
      topic = ForumTopic.start!(board: @board, account: current_account, title: @topic.title, body: @post.body, character: posting_as)
      redirect_to forum_topic_path(topic), notice: "Thread started."
    end
  end

  def show
    @board = @topic.board
    @page = [ params[:page].to_i, 1 ].max
    @pages = [ (@topic.posts.count / ForumTopic::PER_PAGE.to_f).ceil, 1 ].max
    @page = @pages if params[:page] == "last"
    @posts = @topic.posts.includes({ account: { icon_attachment: :blob } }, { character: [ :character_group, { icon_attachment: :blob } ] })
      .offset((@page - 1) * ForumTopic::PER_PAGE).limit(ForumTopic::PER_PAGE)
    @reply = @topic.posts.new if @topic.may_reply?(current_account)
  end

  def edit
  end

  def update
    attrs = params.expect(forum_topic: [ :title, :pinned, :locked ])
    @topic.title = attrs[:title] if attrs.key?(:title)
    if ForumTopic.moderator?(current_account)
      @topic.pinned_at = (attrs[:pinned] == "1" ? (@topic.pinned_at || Time.current) : nil) if attrs.key?(:pinned)
      @topic.locked_at = (attrs[:locked] == "1" ? (@topic.locked_at || Time.current) : nil) if attrs.key?(:locked)
    end
    if @topic.save
      redirect_to forum_topic_path(@topic), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @topic.destroy!
    redirect_to forum_board_path(@topic.board), notice: "Thread deleted."
  end

  private
    def set_board
      @board = ForumBoard.find(params[:forum_board_id])
    end

    def set_topic
      @topic = ForumTopic.find(params[:id])
    end

    # On an in-character board, the character chosen in "Post as".
    def posting_as
      return unless @board.in_character?
      @posting_as ||= @board.characters_for(current_account).find { |character| character.id == params.dig(:forum_topic, :character_id).to_i }
    end

    def require_starter
      redirect_to forum_board_path(@board), alert: "You can't start threads on this board." unless @board.may_start_topic?(current_account)
    end

    def require_editor
      allowed = current_account == @topic.account || ForumTopic.moderator?(current_account)
      redirect_to forum_topic_path(@topic), alert: "Only the thread's starter or a moderator can change it." unless allowed
    end

    def require_moderator
      redirect_to forum_topic_path(@topic), alert: "Only Scribes and Wellkeepers can delete threads." unless ForumTopic.moderator?(current_account)
    end
end
