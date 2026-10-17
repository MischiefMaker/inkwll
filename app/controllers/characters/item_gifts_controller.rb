# A player giving some or all of an item to another character. In a
# Chapter it also shows as a short Passage.
class Characters::ItemGiftsController < Characters::BaseController
  include ItemsRequired
  limit_posting to: 20, within: 10.minutes

  def create
    return back(alert: "#{@character.name} can't give anything away until they're approved.") unless @character.approved? && !@character.retired?
    item = @character.items.find(params[:item_id])
    receiver = Crafting.find_character(params[:to])
    return back(alert: "There's no character called #{params[:to].to_s.squish}.") unless receiver
    return back(alert: "#{@character.name} already has it.") if receiver == @character

    quantity = params[:quantity].presence&.to_i || item.quantity
    moved = item.move_to!(receiver, quantity: quantity)
    what = quantity > 1 ? "#{quantity} × #{moved.name}" : moved.name
    Crafting.log!(moved, "given", character: receiver, other: @character, quantity: quantity, actor: current_account)
    Crafting.alert!(receiver, "#{@character.name} gave #{receiver.name} #{what}.")
    show_in_chapter("#{@character.name} gives #{receiver.name} #{what}.")
    back(notice: "#{@character.name} gave #{receiver.name} #{what}.")
  rescue Crafting::Error => e
    back(alert: e.message)
  end

  private
    def show_in_chapter(text)
      return if params[:scene_id].blank?
      scene = Scene.open.where(id: @character.scene_participants.select(:scene_id)).find_by(id: params[:scene_id])
      scene.add_game_line!(@character, text) if scene&.writable?
    end

    def back(**flash)
      redirect_to character_path(@character, tab: "belongings"), **flash
    end
end
