# Starting a Trade with another character. The offer itself is made on the
# trade's own page.
class Characters::TradesController < Characters::BaseController
  include ItemsRequired
  limit_posting to: 10, within: 10.minutes

  def create
    return redirect_to(character_path(@character, tab: "belongings"), alert: "#{@character.name} can't trade until they're approved.") unless @character.approved? && !@character.retired?
    other = Crafting.find_character(params[:to])
    return redirect_to(character_path(@character, tab: "belongings"), alert: "There's no character called #{params[:to].to_s.squish}.") unless other
    scene = Scene.open.where(id: @character.scene_participants.select(:scene_id)).find_by(id: params[:scene_id]) if params[:scene_id].present?
    trade = Crafting::Trade.create(from_character: @character, to_character: other, scene: scene)
    return redirect_to(character_path(@character, tab: "belongings"), alert: trade.errors.full_messages.to_sentence) unless trade.persisted?
    Crafting.alert!(other, "#{@character.name} wants to trade with #{other.name}.")
    redirect_to trade_path(trade), notice: "Trade started. Add what #{@character.name} offers, then tick Agree."
  end
end
