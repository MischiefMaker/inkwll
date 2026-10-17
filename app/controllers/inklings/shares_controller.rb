# Sharing an Inkling with another character, or everyone in a character
# group or faction. Its player (or staff) decides who it's shared with.
class Inklings::SharesController < Inklings::BaseController
  limit_posting to: 20, within: 10.minutes, only: :create
  before_action :require_sharer

  def create
    if params[:group_id].present?
      group = CharacterGroup.find(params[:group_id])
      @inkling.update!(shared_group_ids: (@inkling.shared_group_ids | [ group.id ]))
      @inkling.add_system_entry!("Shared with everyone in #{group.name}.")
      return back(notice: "Shared with #{group.name}.")
    end
    if params[:faction_id].present?
      faction = shareable_factions.find(params[:faction_id])
      @inkling.update!(shared_faction_ids: (@inkling.shared_faction_ids | [ faction.id ]))
      @inkling.add_system_entry!("Shared with everyone in #{faction.name}.")
      return back(notice: "Shared with #{faction.name}.")
    end
    character = Character.active.where(status: "approved").where("lower(name) = ?", params[:name].to_s.squish.downcase).first
    return back(alert: "There's no character called #{params[:name].to_s.squish}.") unless character
    return back(alert: "That's #{@inkling.character.name}'s own Inkling.") if character == @inkling.character
    @inkling.shares.find_or_create_by!(character: character)
    @inkling.add_system_entry!("Shared with #{character.name}.")
    back(notice: "Shared with #{character.name}.")
  end

  # id is a share's id, "group-<id>" for a group or "faction-<id>" for a faction.
  def destroy
    if (group_id = params[:id].to_s.delete_prefix!("group-"))
      @inkling.update!(shared_group_ids: @inkling.shared_group_ids - [ group_id.to_i ])
    elsif (faction_id = params[:id].to_s.delete_prefix!("faction-"))
      @inkling.update!(shared_faction_ids: @inkling.shared_faction_ids - [ faction_id.to_i ])
    else
      @inkling.shares.find(params[:id]).destroy!
    end
    back(notice: "No longer shared.")
  end

  private
    # The factions the sharer can see: all of them for staff, otherwise the
    # open ones and the secret ones their characters are in.
    def shareable_factions
      Faction.visible_to(current_account)
    end

    def require_sharer
      back(alert: "Only #{@inkling.character.name}'s player can change who sees this.") unless @inkling.owned_by?(current_account) || staff_view?
    end
end
