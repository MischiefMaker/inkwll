# Keeps an account, or everyone at an IP address (or range), out of the game.
# A ban can be permanent or end on a date, and staff can lift it early.
class Ban < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :banned_by, class_name: "Account"

  attribute :player_name, :string
  attribute :expires_on, :date

  validates :reason, presence: true, length: { maximum: 2_000 }
  validate :bans_something

  scope :in_force, -> { where(lifted_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  # The ban in force for this account or IP address, if there is one.
  def self.for(account: nil, ip: nil)
    bans = in_force
    by_account = account ? bans.where(account: account) : none
    by_ip = ip.present? ? bans.where("ip_range >>= ?::inet", ip.to_s) : none
    by_account.or(by_ip).order(:created_at).first
  rescue ActiveRecord::StatementInvalid
    by_account&.first
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
    def bans_something
      errors.add(:base, "Choose an account or an IP address to ban") if account.nil? && ip_range.blank?
    end
end
