# Buying from a Place's shop: the catalogue price leaves the buyer's Purse
# and a copy of the item goes into their Belongings. The buyer has to be
# standing in the Place.
class Rooms::ShopPurchasesController < ApplicationController
  include ItemsRequired
  limit_posting to: 20, within: 10.minutes

  def create
    room = Room.find(params[:room_id])
    listing = Crafting::ShopListing.includes(:catalogue_item).find_by!(room: room, catalogue_item_id: params[:catalogue_item_id])
    buyer = current_account.characters.active.where(status: "approved").find_by(id: params[:character_id])
    return redirect_to(room_path(room), alert: "Pick one of your approved characters to buy it.") unless buyer
    return redirect_to(room_path(room), alert: "#{buyer.name} has to be here to buy something.") unless buyer.room_id == room.id
    catalogue_item = listing.catalogue_item

    Crafting::Item.transaction do
      Economy.account_for(buyer).debit!(catalogue_item.price, kind: "purchase", note: "#{catalogue_item.name} from #{room.name}", actor: current_account) if catalogue_item.price.positive?
      catalogue_item.give_to!(buyer, kind: "bought", note: "#{room.name}, for #{Economy.money(catalogue_item.price)}", actor: current_account)
    end
    redirect_to room_path(room), notice: "#{buyer.name} bought #{catalogue_item.name}."
  rescue Economy::Error => e
    redirect_to room_path(room), alert: e.message
  end
end
