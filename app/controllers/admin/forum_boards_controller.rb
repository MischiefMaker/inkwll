# Forum boards (news, advertising, wanted ads...) and who may start threads
# and reply on each, set up by Scribes and Wellkeepers. Deleting a board deletes all its threads.
class Admin::ForumBoardsController < Admin::BaseController
  require_job :manage_forums
  before_action :set_board, only: %i[ edit update destroy ]

  def index
    @boards = ForumBoard.ordered
    @board = ForumBoard.new
  end

  def create
    @board = ForumBoard.new(board_params)
    @board.position = ForumBoard.maximum(:position).to_i + 1
    if @board.save
      redirect_to admin_forum_boards_path, notice: "#{@board.name} added."
    else
      @boards = ForumBoard.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @board.update(board_params)
      redirect_to admin_forum_boards_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @board.destroy
    redirect_to admin_forum_boards_path, notice: "#{@board.name} deleted."
  end

  private
    def set_board
      @board = ForumBoard.find(params[:id])
    end

    def board_params
      params.expect(forum_board: [ :name, :description, :position, :who_can_start, :who_can_reply, :icon, :remove_icon, :image, :remove_image ])
    end
end
