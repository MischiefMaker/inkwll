# A Trade between two characters: each side puts in money and items, and it
# only goes through once both have ticked Agree to the same offer. Changing
# either side's offer clears both ticks (owner, 2026-10-17).
class Crafting::Trade < ApplicationRecord
  belongs_to :from_character, class_name: "Character"
  belongs_to :to_character, class_name: "Character"
  belongs_to :scene, optional: true
  has_many :trade_items, class_name: "Crafting::TradeItem", dependent: :delete_all

  validates :from_money, :to_money, numericality: { only_integer: true, in: 0..10_000_000 }
  validates :status, inclusion: { in: %w[ open done cancelled ] }
  validate :two_different_characters, on: :create

  scope :open, -> { where(status: "open") }
  scope :involving, ->(characters) { where(from_character: characters).or(where(to_character: characters)) }

  def open? = status == "open"
  def done? = status == "done"
  def characters = [ from_character, to_character ]
  def side(character) = character == from_character ? :from : (character == to_character ? :to : nil)
  def other(character) = character == from_character ? to_character : from_character
  def money_from(character) = side(character) == :from ? from_money : to_money
  def agreed?(character) = side(character) == :from ? from_agreed : to_agreed
  def items_from(character) = trade_items.includes(:item).select { |line| line.item.character_id == character.id }

  # The characters in it an account plays.
  def characters_for(account)
    account ? characters.select { |character| character.account_id == account.id && !character.retired? } : []
  end

  # Replaces one side's offer: money and { item_id => quantity }. Both ticks
  # are cleared, since the offer changed.
  def offer!(character, money:, items:)
    raise Crafting::Error, "This trade is over." unless open?
    money = money.to_i
    raise Crafting::Error, "The money can't be less than nothing." if money.negative?
    transaction do
      lock!
      trade_items.select { |line| line.item.character_id == character.id }.each(&:destroy!)
      items.each do |item_id, quantity|
        quantity = quantity.to_i
        next unless quantity.positive?
        item = character.items.find_by(id: item_id) or raise Crafting::Error, "#{character.name} doesn't have that."
        raise Crafting::Error, "#{character.name} only has #{item.quantity} of #{item.name}." if quantity > item.quantity
        trade_items.create!(item: item, quantity: quantity)
      end
      update!((side(character) == :from ? :from_money : :to_money) => money, from_agreed: false, to_agreed: false)
    end
  end

  # One side agrees. Once both have, it goes through.
  def agree!(character)
    raise Crafting::Error, "This trade is over." unless open?
    with_lock do
      update!((side(character) == :from ? :from_agreed : :to_agreed) => true)
    end
    complete! if from_agreed && to_agreed
  end

  def cancel!
    update!(status: "cancelled") if open?
  end

  def summary_for(character)
    parts = items_from(character).map { |line| line.quantity > 1 ? "#{line.quantity} × #{line.item.name}" : line.item.name }
    parts << Economy.money(money_from(character)) if money_from(character).positive?
    parts.to_sentence.presence || "nothing"
  end

  private
    def two_different_characters
      errors.add(:base, "Pick someone else to trade with.") if from_character_id == to_character_id
    end

    # Checks everything is still there and moves it all at once.
    def complete!
      transaction do
        lock!
        raise Crafting::Error, "This trade is over." unless open?
        text = "#{from_character.name} and #{to_character.name} trade: #{from_character.name} gives #{summary_for(from_character)}, and #{to_character.name} gives #{summary_for(to_character)}."
        # Who gives what is settled before anything moves.
        lines = trade_items.includes(:item).group_by { |line| line.item.character_id }
        characters.each do |giver|
          Array(lines[giver.id]).each do |line|
            raise Crafting::Error, "#{giver.name} no longer has #{line.quantity} of #{line.item.name}." if line.quantity > line.item.quantity
          end
        end
        characters.each do |giver|
          receiver = other(giver)
          if money_from(giver).positive?
            Economy.transfer!(from: Economy.account_for(giver), to: Economy.account_for(receiver), amount: money_from(giver), kind: "trade", note: "Trade")
          end
          Array(lines[giver.id]).each do |line|
            moved = line.item.move_to!(receiver, quantity: line.quantity)
            Crafting.log!(moved, "traded", character: receiver, other: giver, quantity: line.quantity)
          end
        end
        update!(status: "done")
        scene.add_game_line!(from_character, text) if scene&.writable?
      end
    end
end
