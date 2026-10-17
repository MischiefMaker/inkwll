# A payment that goes through on its own every week, two weeks or month,
# such as a salary from a faction's Bank or a parent's allowance. With no
# payer, the game pays (staff set these up). The payer can stop it, and the
# person paid can turn it down.
class Economy::Schedule < ApplicationRecord
  belongs_to :from_account, class_name: "Economy::Account", optional: true
  belongs_to :to_account, class_name: "Economy::Account"
  belongs_to :created_by, class_name: "::Account", optional: true
  belongs_to :created_by_character, class_name: "Character", optional: true

  validates :amount, numericality: { only_integer: true, greater_than: 0, less_than: 10_000_000 }
  validates :interval, inclusion: { in: Economy::INTERVALS.keys }
  validates :note, length: { maximum: 200 }
  validate :not_to_itself

  scope :running, -> { where(stopped_at: nil) }
  scope :due, ->(today = Date.current) { running.where(next_due_on: ..today) }

  def interval_name = Economy::INTERVALS.fetch(interval)

  def payer_name = from_account ? from_account.owner_name : "The game"

  def running? = stopped_at.nil?

  def stop!(reason)
    update!(stopped_at: Time.current, stopped_reason: reason.to_s.first(200))
  end

  # Pays this schedule if it's due. Payments missed while the Economy was
  # off, or more than a couple of days late, are skipped rather than paid
  # late (owner, 2026-10-17: missed payments aren't back-paid).
  def run!(today = Date.current)
    return unless running? && next_due_on <= today
    return stop!("Ended on #{ends_on.to_fs(:long)}") if ends_on && next_due_on > ends_on
    return stop!("#{retired_party.name} retired") if retired_party

    if next_due_on >= today - 2
      key = "schedule:#{id}:#{next_due_on.iso8601}"
      if from_account
        begin
          Economy.transfer!(from: from_account, to: to_account, amount: amount, kind: "scheduled", note: note.presence || "Scheduled payment",
            schedule: self, key: key, actor_character: created_by_character, taxable: true)
        rescue Economy::Error
          from_account.note_missed!(amount, note: note.presence || "Scheduled payment", counterparty: to_account, schedule: self, key: "#{key}:missed:out")
          to_account.note_missed!(amount, note: note.presence || "Scheduled payment", counterparty: from_account, schedule: self, key: "#{key}:missed:in")
          Economy.alert_missed!(self)
        end
      else
        to_account.credit!(amount, kind: "scheduled", note: note.presence || "From the game", key: key, taxable: true)
      end
    end

    date = next_due_on
    date = Economy.next_date(date, interval) while date <= today
    update!(next_due_on: date)
  end

  private
    def retired_party
      [ from_account&.owner, to_account.owner ].find { |owner| owner.is_a?(Character) && owner.retired? }
    end

    def not_to_itself
      errors.add(:base, "A payment can't go to the same Purse or Bank it comes from.") if from_account_id && from_account_id == to_account_id
    end
end
