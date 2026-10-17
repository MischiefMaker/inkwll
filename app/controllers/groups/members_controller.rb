# A member's rank in their group, given by its leaders or staff. Only staff
# tick who leads it.
class Groups::MembersController < ApplicationController
  before_action :set_group
  before_action :require_manager

  def update
    character = @group.members.find(params[:id])
    rank = params.dig(:character, :group_rank).presence
    character.group_rank = rank if rank.nil? || rank.in?(@group.rank_names)
    character.group_leader = params.dig(:character, :group_leader) == "1" if CharacterGroup.staff?(current_account) && params.dig(:character, :group_leader)
    if character.save
      redirect_to group_path(@group), notice: "#{character.name} saved."
    else
      redirect_to group_path(@group), alert: character.errors.full_messages.to_sentence
    end
  end

  private
    def set_group
      @group = CharacterGroup.find(params[:group_id])
    end

    def require_manager
      redirect_to group_path(@group), alert: "Only the group's leaders and staff can change ranks." unless @group.manageable_by?(current_account)
    end
end
