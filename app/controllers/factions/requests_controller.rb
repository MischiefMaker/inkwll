# Asking to join an open faction, for approved characters, and the heads' and
# staff's answer: accept (which adds the member) or decline.
class Factions::RequestsController < ApplicationController
  limit_posting to: 10, within: 10.minutes, only: :create
  before_action -> { raise ActiveRecord::RecordNotFound unless Faction.enabled? }
  before_action :set_faction

  def create
    character = current_account.characters.find(params[:character_id])
    request = @faction.requests.new(character: character, note: params[:note])
    if request.save
      back(notice: "#{character.name} asked to join. The heads and staff will answer.")
    else
      back(alert: request.errors.full_messages.to_sentence)
    end
  end

  def update
    return back(alert: "Only #{@faction.name}'s heads and staff can answer requests.") unless @faction.manageable_by?(current_account)
    request = @faction.requests.pending.find(params[:id])
    if params[:decision] == "accept"
      request.accept!(by: current_account)
      back(notice: "#{request.character.name} joined #{@faction.name}.")
    else
      request.decline!(by: current_account)
      back(notice: "Declined.")
    end
  end

  # A player taking back their own request.
  def destroy
    request = @faction.requests.pending.where(character: current_account.characters).find(params[:id])
    request.destroy!
    back(notice: "Request taken back.")
  end

  private
    def set_faction
      @faction = Faction.visible_to(current_account).find(params[:faction_id])
    end

    def back(**flash)
      redirect_to faction_path(@faction), **flash
    end
end
