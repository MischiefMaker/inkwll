# A character's money (the Economy): their Purse, made the first time it's
# needed. A newly approved character gets the game's starting amount.
module Character::Purse
  extend ActiveSupport::Concern

  included do
    has_one :economy_account, as: :owner, class_name: "Economy::Account", dependent: :destroy
    after_save_commit :give_starting_money, if: -> { saved_change_to_status?(to: "approved") }
  end

  def purse = Economy.account_for(self)

  private
    def give_starting_money
      Economy.give_starting_amount!(self)
    end
end
