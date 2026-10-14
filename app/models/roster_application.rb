# A player applying to take over a character on the roster. Staff approve
# one; the others for the same character are turned down.
class RosterApplication < ApplicationRecord
  belongs_to :character
  belongs_to :account
  belongs_to :reviewed_by, class_name: "Account", optional: true

  enum :status, { pending: "pending", approved: "approved", denied: "denied" }, validate: true

  validates :note, presence: true, length: { maximum: 2_000 }
  validate :character_is_on_the_roster, on: :create
  validate :one_at_a_time, on: :create

  def approve!(by:)
    transaction do
      character.take_over!(account)
      update!(status: "approved", reviewed_by: by, reviewed_at: Time.current)
      character.roster_applications.pending.where.not(id: id)
        .update_all(status: "denied", staff_reason: "Someone else was picked.", reviewed_by_id: by.id, reviewed_at: Time.current)
    end
    NotificationMailer.application_decision(character).deliver_later if account.wants_email?
  end

  def deny!(by:, reason:)
    update!(status: "denied", staff_reason: reason.to_s.strip.first(250).presence, reviewed_by: by, reviewed_at: Time.current)
  end

  private
    def character_is_on_the_roster
      errors.add(:character, "isn't on the roster") unless character&.on_roster?
    end

    def one_at_a_time
      if RosterApplication.pending.exists?(character: character, account: account)
        errors.add(:base, "You've already applied for #{character.name}")
      end
    end
end
