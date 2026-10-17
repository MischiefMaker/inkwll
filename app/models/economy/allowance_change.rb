# A Boon or Bane that changes the weekly allowance of every character who
# has it, such as "Wealthy" (+10) or "Penniless" (-5). Staff set these in
# Admin → Economy; SOUL itself doesn't know about money.
class Economy::AllowanceChange < ApplicationRecord
  belongs_to :bnb, class_name: "Soul::Bnb", foreign_key: :soul_bnb_id

  validates :amount, numericality: { only_integer: true, other_than: 0, in: -1_000_000..1_000_000 }
  validates :soul_bnb_id, uniqueness: true
end
