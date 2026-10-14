# Keeps an account, or everyone at an IP address (or range), out of the game.
# A ban can be permanent or end on a date, and staff can lift it early.
class Ban < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :banned_by, class_name: "Account"

  attribute :player_name, :string
  attribute :expires_on, :date

  validates :reason, presence: true, length: { maximum: 2_000 }
  validate :bans_something
  validate :ip_range_not_too_wide

  scope :in_force, -> { where(lifted_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  # The narrowest IP ranges allowed, so nobody can ban the whole game:
  # a /16 is about 65,000 addresses.
  WIDEST_IPV4_PREFIX = 16
  WIDEST_IPV6_PREFIX = 32

  # The ban in force for this account or IP address, if there is one. An IP
  # ban never applies to the Founder, or to staff at or above the level of
  # whoever set it.
  def self.for(account: nil, ip: nil)
    bans = in_force
    by_account = account ? bans.where(account: account) : none
    by_ip = ip.present? ? bans.where("ip_range >>= ?::inet", ip.to_s) : none
    by_account.or(by_ip).includes(:banned_by).order(:created_at).detect { |ban| ban.account || !ban.protects?(account) }
  rescue ActiveRecord::StatementInvalid
    by_account&.first
  end

  # Whether this (IP) ban leaves the given account alone.
  def protects?(account)
    account.present? && (account.founder? || account.staff_rank >= banned_by.staff_rank)
  end

  # Staff can only lift bans set by someone at their own level or below.
  def liftable_by?(staff)
    staff.founder? || banned_by.staff_rank <= staff.staff_rank
  end

  def in_force?
    lifted_at.nil? && (expires_at.nil? || expires_at.future?)
  end

  def lift!
    update!(lifted_at: Time.current)
  end

  # "until 1 March 2027" or "permanently".
  def duration_in_words
    expires_at ? "until #{expires_at.to_date.to_fs(:long)}" : "permanently"
  end

  private
    def ip_range_not_too_wide
      return if ip_range.blank?
      range = ip_range.is_a?(IPAddr) ? ip_range : IPAddr.new(ip_range.to_s)
      widest = range.ipv4? ? WIDEST_IPV4_PREFIX : WIDEST_IPV6_PREFIX
      errors.add(:ip_range, "is too wide. The widest allowed is /#{widest}") if range.prefix < widest
    rescue IPAddr::InvalidAddressError
      errors.add(:ip_range, "isn't a valid address or range")
    end

    def bans_something
      errors.add(:base, "Choose an account or an IP address to ban") if account.nil? && ip_range.blank?
    end
end
