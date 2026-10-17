# A character's items (Crafting): their Belongings, which everyone can see,
# and the trades they're in.
module Character::Belongings
  extend ActiveSupport::Concern

  included do
    has_many :items, class_name: "Crafting::Item", dependent: :destroy
  end

  def trades = Crafting::Trade.involving(self)
end
