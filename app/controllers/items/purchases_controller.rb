# Buying an item from the Market. The money goes to the seller (and counts
# as their income for faction income tax), and the item moves to the buyer.
class Items::PurchasesController < ApplicationController
  include CraftingRequired
  limit_posting to: 20, within: 10.minutes

  def create
    item = Crafting::Item.for_sale.includes(:character).find(params[:item_id])
    buyer = current_account.characters.active.where(status: "approved").find_by(id: params[:character_id])
    return redirect_to(market_path, alert: "Pick one of your approved characters to buy it.") unless buyer
    return redirect_to(market_path, alert: "#{buyer.name} already owns it.") if item.character == buyer
    seller = item.character
    price = item.price

    Crafting::Item.transaction do
      item.lock!
      raise Crafting::Error, "Someone else just bought it." unless item.for_sale? && item.price == price
      Economy.transfer!(from: Economy.account_for(buyer), to: Economy.account_for(seller), amount: price, kind: "sale", note: item.name, actor: current_account, taxable: true)
      item.move_to!(buyer)
      Crafting.log!(item, "sold", character: buyer, other: seller, note: "For #{Economy.money(price)}", actor: current_account)
    end
    Crafting.alert!(seller, "#{buyer.name} bought #{seller.name}'s #{item.name} on the #{Term[:market]} for #{Economy.money(price)}.")
    redirect_to character_path(buyer, tab: "belongings"), notice: "#{buyer.name} bought #{item.name} for #{Economy.money(price)}."
  rescue Crafting::Error, Economy::Error => e
    redirect_to market_path, alert: e.message
  end
end
