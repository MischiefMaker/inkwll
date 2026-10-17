# A piece of land (docs/economy.md, "Domains"): the Duchy of Niwen, the
# Barony of Everean. Each Domain sits under at most one liege Domain, so the
# land makes a tree, and is held by a character (or, now and then, a faction
# such as a clan). Its people are only a number. Once a month each Domain
# earns people × yield, pays its tax to its liege (on everything it took in,
# its vassals' taxes included), and its holder keeps the rest.
#
# Staff make Domains and set everything about them, except the tax a vassal
# pays, which the liege's holder sets within the game's limit.
class Domain < ApplicationRecord
  belongs_to :liege, class_name: "Domain", optional: true
  belongs_to :holder_character, class_name: "Character", optional: true
  belongs_to :holder_faction, class_name: "Faction", optional: true
  belongs_to :area, optional: true
  has_many :vassals, class_name: "Domain", foreign_key: :liege_id, dependent: :nullify, inverse_of: :liege

  normalizes :name, :rank, with: ->(text) { text.squish.presence }
  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
  validates :rank, length: { maximum: 40 }
  validates :description, length: { maximum: 5000 }
  validates :people, :yield_per_head, numericality: { only_integer: true, in: 0..10_000_000 }
  validates :tax_percent, numericality: { only_integer: true, in: 0..100 }
  validate :one_holder
  validate :no_loops
  validate :tax_within_limit, if: :will_save_change_to_tax_percent?

  scope :ordered, -> { order(:position, :name) }

  def self.enabled?
    Economy.enabled? && GameSetting.current.domains_enabled?
  end

  def self.staff?(account)
    account&.can?(:review_apps) || false
  end

  # Ranks already in use, offered as suggestions when staff make a Domain.
  def self.ranks
    where.not(rank: nil).distinct.order(:rank).pluck(:rank)
  end

  # What every Domain earns this month, worked out bottom-up from the
  # deepest vassals, as { id => { own:, from_vassals:, tax:, kept: } }.
  def self.month_sums(domains = all.to_a)
    vassals = domains.group_by(&:liege_id)
    sums = {}
    work = lambda do |domain|
      sums[domain.id] ||= begin
        from_vassals = vassals.fetch(domain.id, []).sum { |vassal| work.(vassal)[:tax] }
        own = domain.people * domain.yield_per_head
        income = own + from_vassals
        tax = domain.liege_id ? income * domain.tax_percent / 100 : 0
        { own: own, from_vassals: from_vassals, tax: tax, kept: income - tax }
      end
    end
    domains.each { |domain| work.(domain) }
    sums
  end

  # Pays every Domain's month: the holder gets the land's own earnings, each
  # vassal's tax goes to its liege's holder, and the ledgers show each step.
  # Keys stop a month being paid twice. A Domain nobody holds still earns
  # and pays its liege, but its own share goes to no one.
  def self.pay_month!(today = Date.current)
    return unless enabled?
    month = today.strftime("%Y-%m")
    domains = includes(:holder_character, :holder_faction).to_a
    sums = month_sums(domains)
    vassals = domains.group_by(&:liege_id)
    depth = ->(domain, seen = 0) { domain.liege_id && seen < 100 ? 1 + depth.(domains.find { _1.id == domain.liege_id }, seen + 1) : 0 }

    domains.sort_by { -depth.(_1) }.each do |domain|
      account = domain.holder_account
      own = sums[domain.id][:own]
      account&.credit!(own, kind: "domain", note: "#{domain.name}: #{ActiveSupport::NumberHelper.number_to_delimited(domain.people)} people", key: "domain:#{month}:#{domain.id}") if own.positive?
      vassals.fetch(domain.id, []).each do |vassal|
        tax = sums[vassal.id][:tax]
        pay_tax!(vassal, domain, tax, key: "domain:#{month}:#{vassal.id}:tax") if tax.positive?
      end
    end
  end

  def self.pay_tax!(vassal, liege, tax, key:)
    from = vassal.holder_account
    to = liege.holder_account
    note = "Tax from #{vassal.name} to #{liege.name}"
    if from && to
      Economy.transfer!(from: from, to: to, amount: tax, kind: "domain_tax", note: note, key: key) unless from == to
    elsif to
      to.credit!(tax, kind: "domain_tax", note: "#{note} (nobody holds #{vassal.name})", key: key)
    elsif from
      from.with_lock do
        from.record!(-tax, kind: "domain_tax", note: note, key: key) if from.balance >= tax && !Economy::Entry.exists?(key: key)
      end
    end
  rescue Economy::Error
    # The vassal's holder somehow can't cover it: skip rather than go into debt.
  end

  def holder
    holder_character || holder_faction
  end

  # The Purse or Bank the Domain's money goes to. A retired holder holds
  # nothing.
  def holder_account
    if holder_character
      Economy.account_for(holder_character) unless holder_character.retired?
    elsif holder_faction
      Economy.account_for(holder_faction)
    end
  end

  # The holder's player, or the holding faction's Bank managers.
  def held_by?(account)
    return false unless account
    if holder_character
      holder_character.account_id == account.id && !holder_character.retired?
    elsif holder_faction
      holder_faction.bank_manager_character_for(account).present?
    else
      false
    end
  end

  # People, yield, earnings and taxes are private to the holder, the liege's
  # holder (who sets the tax) and staff.
  def details_visible_to?(account)
    self.class.staff?(account) || held_by?(account) || liege&.held_by?(account) || false
  end

  def tax_settable_by?(account)
    liege.present? && (self.class.staff?(account) || liege.held_by?(account))
  end

  private
    def one_holder
      errors.add(:base, "A #{Term[:domain].downcase} is held by a character or a #{Term[:faction].downcase}, not both.") if holder_character_id && holder_faction_id
    end

    def no_loops
      seen = [ id ].compact
      domain = liege
      while domain
        if seen.include?(domain.id)
          errors.add(:liege, "can't be #{name} itself or one of its own vassals")
          break
        end
        seen << domain.id
        domain = domain.liege
      end
    end

    def tax_within_limit
      limit = GameSetting.current.domain_tax_max_percent
      errors.add(:tax_percent, "can be at most #{limit}%") if tax_percent.to_i > limit
    end
end
