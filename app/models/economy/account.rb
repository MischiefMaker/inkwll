# A character's Purse or a faction's Bank. The balance is kept here for
# speed, and every change to it is a line in `entries`, written in the same
# transaction, so the two always agree.
class Economy::Account < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_many :entries, class_name: "Economy::Entry", dependent: :delete_all
  has_many :outgoing_schedules, class_name: "Economy::Schedule", foreign_key: :from_account_id, dependent: :delete_all, inverse_of: :from_account
  has_many :incoming_schedules, class_name: "Economy::Schedule", foreign_key: :to_account_id, dependent: :delete_all, inverse_of: :to_account

  def owner_name = owner&.name || "Someone gone"

  def owner_kind = owner.is_a?(Faction) ? "Bank" : "Purse"

  def bank? = owner_type == "Faction"

  # Adds a ledger line and changes the balance. Callers hold the row lock.
  def record!(amount, kind:, note: nil, counterparty: nil, actor: nil, actor_character: nil, schedule: nil, key: nil)
    self.balance += amount
    save!
    entries.create!(amount: amount, balance_after: balance, kind: kind, note: note.to_s.squish.first(200).presence, counterparty: counterparty,
      actor: actor, actor_character: actor_character, schedule: schedule, key: key)
  end

  # Money arriving from the game (staff, the allowance, a Domain's land).
  # A key stops the same payment twice.
  def credit!(amount, kind:, note: nil, actor: nil, key: nil, taxable: false)
    amount = amount.to_i
    raise Economy::Error, "The amount must be a whole number above 0." unless amount.positive?
    return if key && Economy::Entry.exists?(key: key)
    transaction do
      lock!
      record!(amount, kind: kind, note: note, actor: actor, key: key)
    end
    Economy.take_income_tax!(self, amount, key: key) if taxable
  end

  # Money staff take away. It can't go below nothing.
  def debit!(amount, kind:, note: nil, actor: nil)
    amount = amount.to_i
    raise Economy::Error, "The amount must be a whole number above 0." unless amount.positive?
    transaction do
      lock!
      raise Economy::Error, "#{owner_name} only has #{Economy.money(balance)}." if balance < amount
      record!(-amount, kind: kind, note: note, actor: actor)
    end
  end

  # A payment that couldn't go through: a line with no money, so both sides
  # (and a Bank's managers) can see it was missed.
  def note_missed!(amount, note:, counterparty: nil, schedule: nil, key: nil)
    return if key && Economy::Entry.exists?(key: key)
    entries.create!(amount: 0, balance_after: balance, kind: "missed", note: "#{note} (#{Economy.money(amount)}) couldn't be paid".first(200),
      counterparty: counterparty, schedule: schedule, key: key)
  end
end
