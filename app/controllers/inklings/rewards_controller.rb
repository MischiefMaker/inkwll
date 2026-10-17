# Staff granting a reward for an Inkling: XP, a Boon or Bane, progressing
# one, a Culmination, a note, money, or an item from the catalogue.
class Inklings::RewardsController < Inklings::BaseController
  before_action :require_staff_view

  def create
    @inkling.reward!(by: current_account, type: params[:reward_type].to_s, amount: params[:amount],
      bnb: Soul::Bnb.active.find_by(id: params[:bnb_id]), level: params[:level],
      entry: @inkling.character.character_bnbs.find_by(id: params[:character_bnb_id]),
      title: params[:title].to_s.strip.presence, note: params[:note].to_s.strip.presence, private: params[:visible_to_all] != "1",
      catalogue_item: (Crafting::CatalogueItem.find_by(id: params[:catalogue_item_id]) if Crafting.items_enabled?))
    back(notice: "Reward granted.")
  rescue ArgumentError => e
    back(alert: e.message)
  end
end
