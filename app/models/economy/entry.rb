# One line on a Purse's or Bank's ledger. Lines are never changed or
# removed; a mistake is put right with another line.
class Economy::Entry < ApplicationRecord
  KINDS = {
    "payment" => "Payment",
    "scheduled" => "Scheduled payment",
    "allowance" => "Weekly allowance",
    "starting" => "Starting money",
    "staff" => "From staff",
    "staff_take" => "Taken by staff",
    "inkling" => "Inkling reward",
    "tax" => "Income tax",
    "dues" => "Dues",
    "domain" => "Land",
    "domain_tax" => "Land tax",
    "sale" => "Sale",
    "purchase" => "Purchase",
    "craft" => "Crafting",
    "trade" => "Trade",
    "missed" => "Missed payment"
  }.freeze

  belongs_to :account, class_name: "Economy::Account"
  belongs_to :counterparty, class_name: "Economy::Account", optional: true
  belongs_to :actor, class_name: "::Account", optional: true
  belongs_to :actor_character, class_name: "Character", optional: true
  belongs_to :schedule, class_name: "Economy::Schedule", optional: true

  validates :kind, inclusion: { in: KINDS.keys }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def kind_name = KINDS.fetch(kind)

  def missed? = kind == "missed"

  # "From Wren", "To the Weavers' Guild Bank", or nothing for the game.
  def other_side
    return unless counterparty
    name = counterparty.bank? ? "#{counterparty.owner_name} #{Economy.bank_word}" : counterparty.owner_name
    amount.negative? ? "to #{name}" : "from #{name}"
  end
end
