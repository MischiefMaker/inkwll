# Putting an item on the Market at a price its owner chooses, or taking it
# down again.
class Items::ListingsController < ApplicationController
  include CraftingRequired
  limit_posting to: 20, within: 10.minutes
  before_action :set_item

  def create
    return back(alert: "#{@item.character.name} can't sell until they're approved.") unless @item.character.approved? && !@item.character.retired?
    if @item.update(price: params[:price].to_i, listed_at: Time.current)
      back(notice: "#{@item.name} is on the #{Term[:market]} for #{Economy.money(@item.price)}.")
    else
      @item.restore_attributes
      back(alert: "Pick a price of at least #{Economy.money(1)}.")
    end
  end

  def destroy
    @item.update!(price: nil, listed_at: nil)
    back(notice: "#{@item.name} is off the #{Term[:market]}.")
  end

  private
    def set_item
      @item = Crafting::Item.where(character: current_account.editable_characters).find(params[:item_id])
    end

    def back(**flash)
      redirect_to item_path(@item), **flash
    end
end
