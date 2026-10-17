# The Economy (docs/economy.md): one kind of money, a Purse for every
# character and a Bank for every faction. Money moves by one-off payments,
# scheduled payments, faction taxes and dues, and the weekly allowance, and
# every movement is a line on a ledger. Only staff create money.
#
# It's off until a game switches it on, and doesn't need SOUL. When SOUL is
# on, Boons and Banes staff mark can change a character's allowance; the
# Economy only asks the character which ones they have.
module Economy
  INTERVALS = { "week" => "every week", "fortnight" => "every two weeks", "month" => "every month" }.freeze

  class Error < StandardError; end

  def self.table_name_prefix = "economy_"

  def self.enabled?
    GameSetting.current.economy_enabled?
  end

  def self.taxes_enabled?
    enabled? && GameSetting.current.economy_taxes_enabled?
  end

  # "1 crown", "12 crowns", or "£12" when the game has a symbol.
  def self.money(amount)
    settings = GameSetting.current
    amount = amount.to_i
    return "#{"-" if amount.negative?}#{settings.currency_symbol}#{ActiveSupport::NumberHelper.number_to_delimited(amount.abs)}" if settings.currency_symbol.present?
    "#{ActiveSupport::NumberHelper.number_to_delimited(amount)} #{amount.abs == 1 ? settings.currency_one : settings.currency_other}"
  end

  def self.bank_word = Term[:bank]

  def self.currency_name(count = 2)
    count == 1 ? GameSetting.current.currency_one : GameSetting.current.currency_other
  end

  # The date after `date` for a schedule that repeats every `interval`.
  def self.next_date(date, interval)
    case interval
    when "fortnight" then date + 14
    when "month" then date.next_month
    else date + 7
    end
  end

  # The Purse or Bank that belongs to a character or faction, made the first
  # time it's needed. A character approved before the Economy was switched
  # on gets the starting amount when their Purse is made.
  def self.account_for(owner)
    account = Economy::Account.find_or_create_by!(owner: owner)
    Economy.give_starting_amount!(owner) if owner.is_a?(Character) && owner.approved?
    account
  rescue ActiveRecord::RecordNotUnique
    Economy::Account.find_by!(owner: owner)
  end

  def self.give_starting_amount!(character)
    amount = GameSetting.current.economy_starting_amount
    return unless enabled? && amount.positive?
    Economy::Account.find_or_create_by!(owner: character).credit!(amount, kind: "starting", note: "Starting #{currency_name}", key: "starting:#{character.id}")
  end

  # Moves money from one account to another as two ledger lines. Raises
  # Economy::Error when the payer can't cover it. With `taxable`, the
  # recipient's factions take their income tax as it arrives.
  def self.transfer!(from:, to:, amount:, kind:, note: nil, actor: nil, actor_character: nil, schedule: nil, key: nil, taxable: false)
    amount = amount.to_i
    raise Error, "The amount must be a whole number above 0." unless amount.positive?
    raise Error, "That's the same #{from.owner_kind.downcase}." if from == to
    return if key && Economy::Entry.exists?(key: "#{key}:in")

    Economy::Account.transaction do
      first, second = [ from, to ].sort_by(&:id)
      first.lock!
      second.lock!
      raise Error, "#{from.owner_name} doesn't have #{money(amount)}." if from.balance < amount
      from.record!(-amount, kind: kind, note: note, counterparty: to, actor: actor, actor_character: actor_character, schedule: schedule, key: key && "#{key}:out")
      to.record!(amount, kind: kind, note: note, counterparty: from, actor: actor, actor_character: actor_character, schedule: schedule, key: key && "#{key}:in")
    end
    take_income_tax!(to, amount, key: key) if taxable
  end

  # Each faction the recipient is in takes its percentage of the income, in
  # the factions' order, never more than is left (owner, 2026-10-17: each
  # faction taxes its own members separately).
  def self.take_income_tax!(account, amount, key: nil)
    return unless taxes_enabled? && account.owner.is_a?(Character)
    left = amount
    account.owner.factions.where("income_tax_percent > 0").merge(Faction.ordered).each do |faction|
      tax = [ amount * faction.income_tax_percent / 100, left ].min
      next unless tax.positive?
      begin
        transfer!(from: account, to: faction.bank, amount: tax, kind: "tax", note: "Income tax (#{faction.income_tax_percent}%)", key: key && "#{key}:tax:#{faction.id}")
        left -= tax
      rescue Error
        # Spent before the tax was taken: nothing to take.
      end
    end
  end

  # A character's weekly allowance: the game's amount, changed by any Boons
  # and Banes staff marked (only while SOUL is on), never below 0.
  def self.allowance_for(character)
    base = GameSetting.current.economy_allowance
    return base unless Soul.enabled?
    changes = Economy::AllowanceChange.where(soul_bnb_id: character.character_bnbs.unresolved.select(:soul_bnb_id)).sum(:amount)
    [ base + changes, 0 ].max
  end

  # Tells the player of a character (or a Bank's managers) about money.
  def self.alert!(account, note)
    owner = account.owner
    accounts = owner.is_a?(Character) ? [ owner.account ].compact : owner.bank_manager_accounts
    accounts.uniq.each do |player|
      Alert.notify!(player, "money", character: (owner if owner.is_a?(Character)), faction: (owner if owner.is_a?(Faction)), note: note)
    end
  end

  def self.alert_missed!(schedule)
    text = "A scheduled payment of #{money(schedule.amount)} from #{schedule.payer_name} to #{schedule.to_account.owner_name} couldn't go through."
    alert!(schedule.from_account, text) if schedule.from_account
    alert!(schedule.to_account, text)
  end

  # Pays every scheduled payment and faction dues that are due. Run daily.
  def self.run_due!(today = Date.current)
    return unless enabled?
    Economy::Schedule.due(today).find_each { |schedule| schedule.run!(today) }
    Faction.where("dues_amount > 0").where(dues_next_on: ..today).find_each { |faction| faction.collect_dues!(today) } if taxes_enabled?
  end

  # The weekly allowance for every approved character being played.
  def self.pay_allowances!(now = Time.current)
    return unless enabled?
    week = "#{now.to_date.cwyear}-#{now.to_date.cweek}"
    Character.active.where(status: "approved", on_roster_at: nil).find_each do |character|
      amount = allowance_for(character)
      next unless amount.positive?
      account_for(character).credit!(amount, kind: "allowance", note: "Weekly allowance", key: "allowance:#{week}:#{character.id}", taxable: true)
    end
  end

  # The Purse or Bank a payment by name goes to: a character being played,
  # or a faction the payer can see.
  def self.find_payee(name, viewer)
    name = name.to_s.squish.downcase
    return if name.blank?
    character = Character.active.where(status: "approved").where("lower(name) = ?", name).first
    return account_for(character) if character
    faction = Faction.enabled? && Faction.visible_to(viewer).where("lower(name) = ?", name.delete_suffix(" #{bank_word.downcase}")).first
    account_for(faction) if faction
  end
end
