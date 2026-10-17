# A player paying money from their character's Purse to another character
# or a faction's Bank, once. It can also show in a Chapter as a Passage.
class Characters::PaymentsController < Characters::BaseController
  include EconomyRequired
  limit_posting to: 20, within: 10.minutes

  def create
    return back(alert: "#{@character.name} can't pay anyone until they're approved.") unless @character.approved? && !@character.retired?
    payee = Economy.find_payee(params[:to], current_account)
    return back(alert: "There's no character or #{term_faction} called #{params[:to].to_s.squish}.") unless payee

    amount = params[:amount].to_i
    Economy.transfer!(from: @character.purse, to: payee, amount: amount, kind: "payment", note: params[:note], actor: current_account)
    Economy.alert!(payee, "#{@character.name} paid #{payee.bank? ? "the #{payee.owner_name} #{Economy.bank_word}" : "you"} #{Economy.money(amount)}#{": #{params[:note].to_s.squish.first(100)}" if params[:note].present?}.")
    show_in_chapter(payee, amount)
    back(notice: "#{@character.name} paid #{payee.owner_name} #{Economy.money(amount)}.")
  rescue Economy::Error => e
    back(alert: e.message)
  end

  private
    def term_faction = Term[:faction].downcase

    # "Wren hands Sable 5 crowns." in a Chapter the payer is in.
    def show_in_chapter(payee, amount)
      return if params[:scene_id].blank?
      scene = Scene.open.where(id: @character.scene_participants.select(:scene_id)).find_by(id: params[:scene_id])
      return unless scene&.writable?
      scene.add_game_line!(@character, "#{@character.name} hands #{payee.bank? ? "the #{payee.owner_name}" : payee.owner_name} #{Economy.money(amount)}.")
    end

    def back(**flash)
      redirect_to character_path(@character, tab: "purse"), **flash
    end
end
