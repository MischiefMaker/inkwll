# An item's own page: its pictures, description, features and maker's mark,
# which anyone can see, like Belongings. Its owner can name its flaw.
class ItemsController < ApplicationController
  include ItemsRequired
  allow_previews only: :show
  limit_posting to: 20, within: 10.minutes, only: :update

  def show
    @item = Crafting::Item.includes(:character, :maker, :item_type).find(params[:id])
    raise ActiveRecord::RecordNotFound unless @item.character.approved?
    @mine = current_account.present? && current_account.editable_characters.exists?(@item.character_id)
    @staff = current_account&.can?(:review_apps) || false
    @events = @item.events.newest_first.includes(:character, :other_character).limit(50) if @mine || @staff
  end

  # The owner names a flaw their item came out with.
  def update
    item = Crafting::Item.where(character: current_account.editable_characters).find(params[:id])
    return redirect_to(item_path(item), alert: "Only a flaw can be renamed.") unless item.flaw_name
    if item.update(flaw_name: params.dig(:item, :flaw_name).presence || item.flaw_name)
      redirect_to item_path(item), notice: "Saved."
    else
      redirect_to item_path(item), alert: item.errors.full_messages.to_sentence
    end
  end
end
