# Shared by the actions on a faction's Bank. Only its Bank managers and
# staff get in, and a manager acts as their character, so every Bank action
# is signed with a name the members can see.
class Factions::BankBaseController < ApplicationController
  include EconomyRequired
  before_action -> { raise ActiveRecord::RecordNotFound unless Faction.enabled? }
  before_action :set_faction

  private
    def set_faction
      @faction = Faction.visible_to(current_account).find(params[:faction_id])
      return back(alert: "Only #{@faction.name}'s #{Term[:bank].downcase} managers and staff can do that.") unless @faction.bank_manager?(current_account)
      @manager = @faction.bank_manager_character_for(current_account)
      @bank = @faction.bank
    end

    def signed_by
      @manager ? @manager.name : "Staff"
    end

    def back(**flash)
      redirect_to faction_path(@faction, anchor: "bank"), **flash
    end
end
