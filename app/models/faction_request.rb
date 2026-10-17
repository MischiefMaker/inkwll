# An approved character asking to join an open (not secret) faction. The
# faction's heads get an alert, and staff see it waiting under the bell.
# A head or staff member accepts it, which makes the membership, or declines
# it; either way the asking player gets an alert.
class FactionRequest < ApplicationRecord
  belongs_to :faction
  belongs_to :character
  belongs_to :decided_by, class_name: "Account", optional: true

  enum :status, { pending: "pending", accepted: "accepted", declined: "declined" }, validate: true

  normalizes :note, with: ->(n) { n.squish.presence }
  validates :note, length: { maximum: 500 }
  validate :can_ask, on: :create

  after_create_commit :tell_heads
  after_commit -> { StaffWaiting.refresh_bells! }

  # The characters an account could ask to join this faction with.
  def self.askable_characters(account, faction)
    return Character.none if account.nil? || faction.secret?
    account.characters.active.where(status: "approved", on_roster_at: nil)
      .where.not(id: faction.memberships.select(:character_id))
      .where.not(id: faction.requests.pending.select(:character_id))
      .order(:name)
  end

  def accept!(by:)
    transaction do
      update!(status: "accepted", decided_by: by, decided_at: Time.current)
      faction.memberships.find_or_create_by!(character: character)
    end
    Alert.notify!(character.account, "faction_accepted", faction: faction, character: character)
  end

  def decline!(by:)
    update!(status: "declined", decided_by: by, decided_at: Time.current)
    Alert.notify!(character.account, "faction_declined", faction: faction, character: character)
  end

  private
    def can_ask
      return unless faction && character
      if faction.secret?
        errors.add(:base, "Nobody can ask to join a secret #{Term[:faction].downcase}.")
      elsif !character.approved? || character.retired? || character.gm? || character.on_roster?
        errors.add(:base, "Only approved characters can ask to join.")
      elsif faction.memberships.exists?(character: character)
        errors.add(:base, "#{character.name} is already in #{faction.name}.")
      elsif faction.requests.pending.exists?(character: character)
        errors.add(:base, "#{character.name} has already asked.")
      end
    end

    # One alert for each head's player (staff see it under the bell).
    def tell_heads
      heads = Account.where(id: faction.memberships.where(head: true).joins(:character).merge(Character.active).select("characters.account_id"))
      heads.where.not(id: character.account_id).find_each do |account|
        Alert.notify!(account, "faction_request", faction: faction, character: character)
      end
    end
end
