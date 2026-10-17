module EconomyHelper
  def money(amount)
    Economy.money(amount)
  end

  # A ledger amount: "+5 crowns" or "-5 crowns".
  def signed_money(amount)
    amount.positive? ? "+#{money(amount)}" : money(amount)
  end

  def interval_options
    Economy::INTERVALS.map { |key, label| [ label.capitalize, key ] }
  end

  # Who did a ledger line: a Bank manager's character, or staff.
  def entry_signature(entry)
    if entry.actor_character
      "by #{entry.actor_character.name}"
    elsif entry.actor&.staff? && entry.kind.in?(%w[ staff staff_take payment scheduled ])
      "by staff"
    end
  end
end
