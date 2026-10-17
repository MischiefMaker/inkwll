# The Market: every item for sale in the game on one page. Anyone can
# browse it; players buy with one of their characters.
class MarketController < ApplicationController
  include CraftingRequired
  allow_previews

  def index
    @items = Crafting::Item.for_sale.joins(:character).merge(Character.active).includes(:character, :maker, pictures_attachments: :blob).order(listed_at: :desc)
    @buyers = current_account ? current_account.characters.active.where(status: "approved").order(:name) : Character.none
  end
end
