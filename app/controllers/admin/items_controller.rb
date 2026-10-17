# Staff giving, changing or taking a character's items, always with a
# reason, which goes in the item's history.
class Admin::ItemsController < Admin::BaseController
  include ItemsRequired
  require_job :review_apps
  limit_posting to: 60, within: 10.minutes, only: %i[ create update destroy ]
  before_action :set_item, only: %i[ edit update destroy ]

  # Gives a catalogue item, or a new one staff describe.
  def create
    character = Crafting.find_character(params[:to]) or return back(alert: "There's no approved character called #{params[:to].to_s.squish}.")
    reason = params[:reason].to_s.squish
    return back(alert: "Give a reason.") if reason.blank?
    quantity = [ params[:quantity].to_i, 1 ].max
    if (catalogue_item = Crafting::CatalogueItem.find_by(id: params[:catalogue_item_id]))
      item = catalogue_item.give_to!(character, kind: "staff_give", quantity: quantity, note: reason, actor: current_account)
    else
      item = character.items.new(name: params[:name], quantity: quantity)
      return back(alert: item.errors.full_messages.to_sentence) unless item.save
      Crafting.log!(item, "staff_give", character: character, note: reason, actor: current_account)
    end
    Crafting.alert!(character, "Staff gave #{character.name} #{item.name}: #{reason}")
    back(notice: "Gave #{character.name} #{item.name}.")
  end

  def edit
  end

  def update
    reason = params[:reason].to_s.squish
    return redirect_to(edit_admin_item_path(@item), alert: "Give a reason.") if reason.blank?
    attributes = params.expect(crafting_item: [ :name, :description, :quantity, :flaw_name, feature_ids: [] ])
    attributes[:feature_ids] = Array(attributes[:feature_ids]).compact_blank.map(&:to_i) if attributes.key?(:feature_ids)
    if @item.update(attributes)
      Crafting.log!(@item, "staff_edit", character: @item.character, note: reason, actor: current_account)
      redirect_to item_path(@item), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    reason = params[:reason].to_s.squish
    return redirect_to(edit_admin_item_path(@item), alert: "Give a reason.") if reason.blank?
    Crafting.log!(@item, "staff_take", character: @item.character, note: reason, actor: current_account)
    character = @item.character
    @item.destroy
    Crafting.alert!(character, "Staff took #{character.name}'s #{@item.name}: #{reason}")
    redirect_to character_path(character, tab: "belongings"), notice: "Took #{@item.name}."
  end

  private
    def set_item
      @item = Crafting::Item.find(params[:id])
    end

    def back(**flash)
      redirect_to admin_catalogue_items_path, **flash
    end
end
