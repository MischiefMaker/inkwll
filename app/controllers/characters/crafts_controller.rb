# Making an item: the player picks an item type, writes it up, adds
# pictures and features, and rolls the item type's Skill (docs/crafting.md).
class Characters::CraftsController < Characters::BaseController
  include CraftingRequired
  limit_posting to: 10, within: 10.minutes

  def new
    @item_types = Crafting::ItemType.ordered.includes(:skill)
    @features = Crafting::Feature.approved.where(level: Crafting.levels).ordered
  end

  def create
    item_type = Crafting::ItemType.find_by(id: params[:item_type_id])
    return back(alert: "Pick what to make.") unless item_type
    features = Crafting::Feature.where(id: Array(params[:feature_ids]).compact_blank).to_a
    bnbs = @character.active_bnbs.select { |entry| Array(params[:bnb_ids]).map(&:to_i).include?(entry.id) }
    extras = @character.roll_extras_for_keys(params[:extra_keys])
    scene = Scene.open.where(id: @character.scene_participants.select(:scene_id)).find_by(id: params[:scene_id]) if params[:scene_id].present?
    pictures = Array(params[:pictures]).compact_blank.first(Crafting::Item::MAX_PICTURES)

    item, text = Crafting.craft!(@character, item_type: item_type, name: params[:name], description: params[:description], features: features,
      pictures: pictures, bnbs: bnbs, extras: extras, scene: scene, actor: current_account)
    if item
      redirect_to item_path(item), notice: text
    else
      redirect_to character_path(@character, tab: "belongings"), alert: text
    end
  rescue Crafting::Error, Economy::Error => e
    back(alert: e.message)
  end

  private
    def back(**flash)
      redirect_to new_character_craft_path(@character), **flash
    end
end
