# A family, guild, club or other circle characters belong to. Unlike a
# character group (one per character, colours names), a character can be in
# many factions. Staff make factions; players pick the open ones on their
# application, and heads and staff add members after that.
#
# A secret faction is only seen by its members and staff. In any faction, a
# membership can be secret too: only that character's player, the faction's
# heads and staff see it. A head can be an NPC (just a name) or a character
# on the roster; staff run the faction for them, so games are nudged to give
# each faction several player heads.
#
# With the Economy on, each faction has a Bank (docs/economy.md). Its
# members can read it; members staff tick as Bank managers (and staff) pay
# from it, run its scheduled payments and set its taxes and dues.
class Faction < ApplicationRecord
  has_many :memberships, class_name: "FactionMembership", dependent: :delete_all
  has_many :characters, through: :memberships
  has_many :requests, class_name: "FactionRequest", dependent: :delete_all
  has_one :economy_account, as: :owner, class_name: "Economy::Account", dependent: :destroy

  normalizes :name, with: ->(n) { n.squish }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 5000 }
  validates :npc_heads, length: { maximum: 300 }
  validates :income_tax_percent, numericality: { only_integer: true, in: 0..100 }
  validates :dues_amount, numericality: { only_integer: true, in: 0..10_000_000 }
  validates :dues_interval, inclusion: { in: Economy::INTERVALS.keys }
  validate :taxes_within_limits, if: -> { will_save_change_to_income_tax_percent? || will_save_change_to_dues_amount? }

  scope :ordered, -> { order(:position, :name) }
  # The factions a player can tick on their character's application.
  scope :pickable, -> { where(secret: false, pick_on_application: true) }

  def self.enabled?
    GameSetting.current.factions_enabled?
  end

  # Staff who see every faction and every membership, and manage them all.
  def self.staff?(account)
    account&.can?(:review_apps) || false
  end

  # The factions an account (or a guest, nil) can see.
  def self.visible_to(account)
    return all if staff?(account)
    return where(secret: false) unless account
    where(secret: false).or(where(id: FactionMembership.where(character_id: account.characters.active.select(:id)).select(:faction_id)))
  end

  def visible_to?(account)
    !secret? || self.class.staff?(account) || member_account?(account)
  end

  def member_account?(account)
    account.present? && memberships.where(character_id: account.characters.active.select(:id)).exists?
  end

  def head_account?(account)
    account.present? && memberships.where(head: true, character_id: account.characters.active.select(:id)).exists?
  end

  # The NPC heads' names, from the comma-separated list staff type in.
  def npc_head_names
    npc_heads.to_s.split(",").map(&:squish).compact_blank
  end

  # Whether a player (not staff) runs it: a head who is played and not on
  # the roster. Otherwise staff look after it.
  def player_heads?
    memberships.where(head: true).joins(:character).merge(Character.active.where(on_roster_at: nil, status: "approved")).exists?
  end

  # Heads and staff add, change and remove members.
  def manageable_by?(account)
    self.class.staff?(account) || head_account?(account)
  end

  # The members an account can see: approved characters still being played,
  # without secret memberships unless the account may see them.
  def visible_memberships_for(account)
    shown = memberships.joins(:character).merge(Character.active.where(status: "approved"))
      .includes(character: [ :character_group, { icon_attachment: :blob } ])
      .order(head: :desc).order("characters.name")
    return shown if manageable_by?(account)
    mine = account ? account.characters.select(:id) : []
    shown.where(secret: false).or(shown.where(character_id: mine))
  end

  # --- The Bank (Economy) ------------------------------------------------------

  def bank = Economy.account_for(self)

  # Members and staff can read the Bank.
  def bank_visible_to?(account)
    self.class.staff?(account) || member_account?(account)
  end

  # Bank managers and staff pay from it and set its taxes.
  def bank_manager?(account)
    self.class.staff?(account) || bank_manager_character_for(account).present?
  end

  # The manager character an account acts as, so Bank actions are signed
  # with a character's name.
  def bank_manager_character_for(account)
    return unless account
    memberships.where(bank_manager: true, character_id: account.characters.active.select(:id)).first&.character
  end

  def bank_manager_accounts
    Account.where(id: Character.active.where(id: memberships.where(bank_manager: true).select(:character_id)).select(:account_id))
  end

  # Members who pay dues and income tax: approved characters being played.
  def paying_members
    Character.active.where(status: "approved", on_roster_at: nil, id: memberships.select(:character_id))
  end

  # Each paying member pays the dues into the Bank. Someone who can't pay
  # isn't pushed into debt: it's noted on both ledgers for the managers.
  def collect_dues!(today = Date.current)
    return unless dues_amount.positive? && dues_next_on && dues_next_on <= today
    if dues_next_on >= today - 2
      paying_members.find_each do |character|
        key = "dues:#{id}:#{dues_next_on.iso8601}:#{character.id}"
        begin
          Economy.transfer!(from: character.purse, to: bank, amount: dues_amount, kind: "dues", note: "#{name} dues", key: key)
        rescue Economy::Error
          character.purse.note_missed!(dues_amount, note: "#{name} dues", counterparty: bank, key: "#{key}:missed:out")
          bank.note_missed!(dues_amount, note: "#{name} dues from #{character.name}", counterparty: character.purse, key: "#{key}:missed:in")
        end
      end
    end
    date = dues_next_on
    date = Economy.next_date(date, dues_interval) while date <= today
    update_column(:dues_next_on, date)
  end

  private
    def taxes_within_limits
      settings = GameSetting.current
      if income_tax_percent > settings.economy_tax_max_percent
        errors.add(:income_tax_percent, "can be at most #{settings.economy_tax_max_percent}%")
      end
      if settings.economy_dues_max.positive? && dues_amount > settings.economy_dues_max
        errors.add(:dues_amount, "can be at most #{Economy.money(settings.economy_dues_max)}")
      end
    end
end
