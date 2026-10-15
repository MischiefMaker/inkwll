# Forum boards: the list of them, and one board's threads.
class ForumBoardsController < ApplicationController
  # Guests can read the boards, but not post (owner).
  allow_previews

  def index
    @boards = ForumBoard.ordered.with_attached_icon.with_attached_image
  end

  def show
    @board = ForumBoard.find(params[:id])
    @page = [ params[:page].to_i, 1 ].max
    @topics = @board.ordered_topics.includes(:account).offset((@page - 1) * ForumTopic::PER_PAGE).limit(ForumTopic::PER_PAGE)
    @pages = (@board.topics.count / ForumTopic::PER_PAGE.to_f).ceil
  end
end
