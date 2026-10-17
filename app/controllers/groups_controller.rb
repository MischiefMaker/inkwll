# A character group's page, which everyone can read: its members by rank, its
# leaders and its in-character board. Leaders and staff change its ranks.
class GroupsController < ApplicationController
  allow_previews only: :show
  before_action :set_group
  before_action :require_manager, only: :update

  def show
    @members = @group.members_by_rank
    @manager = @group.manageable_by?(current_account)
    @staff = CharacterGroup.staff?(current_account)
    @board = @group.board!
    @topics = @board.ordered_topics.includes(:account, :character).limit(5)
  end

  def update
    if @group.update(ranks: params.dig(:character_group, :ranks).to_s.first(2_000))
      redirect_to group_path(@group), notice: "Ranks saved."
    else
      redirect_to group_path(@group), alert: "The ranks #{@group.errors[:ranks].to_sentence}."
    end
  end

  private
    def set_group
      @group = CharacterGroup.find(params[:id])
    end

    def require_manager
      redirect_to group_path(@group), alert: "Only the group's leaders and staff can change its ranks." unless @group.manageable_by?(current_account)
    end
end
