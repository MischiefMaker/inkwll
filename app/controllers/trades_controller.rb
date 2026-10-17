# A Trade between two characters. Each side's player sets what their
# character puts in and ticks Agree; once both have agreed to the same
# offer it goes through. Staff can look at any trade.
class TradesController < ApplicationController
  include ItemsRequired
  limit_posting to: 30, within: 10.minutes, only: %i[ update agree ]
  before_action :set_trade, except: :index
  before_action :set_character, only: %i[ update agree destroy ]

  def index
    @trades = Crafting::Trade.open.involving(current_account.characters).includes(:from_character, :to_character).order(updated_at: :desc)
  end

  def show
    @mine = @trade.characters_for(current_account)
    raise ActiveRecord::RecordNotFound unless @mine.any? || current_account.can?(:review_apps)
  end

  def update
    items = params[:items].respond_to?(:to_unsafe_h) ? params[:items].to_unsafe_h : {}
    @trade.offer!(@character, money: params[:money], items: items)
    other = @trade.other(@character)
    Crafting.alert!(other, "#{@character.name} changed their offer in the trade with #{other.name}.")
    redirect_to trade_path(@trade), notice: "Offer saved. Both sides need to tick Agree again."
  rescue Crafting::Error => e
    redirect_to trade_path(@trade), alert: e.message
  end

  def agree
    @trade.agree!(@character)
    other = @trade.other(@character)
    if @trade.reload.done?
      Crafting.alert!(other, "The trade between #{@character.name} and #{other.name} went through.")
      redirect_to character_path(@character, tab: "belongings"), notice: "The trade went through."
    else
      Crafting.alert!(other, "#{@character.name} agreed to the trade with #{other.name}. It goes through when #{other.name} agrees too.")
      redirect_to trade_path(@trade), notice: "Agreed. It goes through when #{other.name} agrees too."
    end
  rescue Crafting::Error, Economy::Error => e
    @trade.update_columns(from_agreed: false, to_agreed: false) if @trade.open?
    redirect_to trade_path(@trade), alert: "The trade couldn't go through: #{e.message}"
  end

  def destroy
    @trade.cancel!
    Crafting.alert!(@trade.other(@character), "#{@character.name} called off the trade with #{@trade.other(@character).name}.")
    redirect_to character_path(@character, tab: "belongings"), notice: "Trade called off."
  end

  private
    def set_trade
      @trade = Crafting::Trade.includes(:from_character, :to_character, trade_items: :item).find(params[:id])
    end

    # The side of the trade this player is acting for.
    def set_character
      mine = @trade.characters_for(current_account)
      @character = mine.find { |character| character.id == params[:character_id].to_i } || mine.first
      return redirect_to(trade_path(@trade), alert: "Only the two players in this trade can do that.") unless @character
      redirect_to(trade_path(@trade), alert: "This trade is over.") unless @trade.open?
    end
end
