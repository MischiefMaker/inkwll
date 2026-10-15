# A player applying to take over a character on the roster. Staff approve
# one; the others for the same character are turned down.
class RosterApplication < ApplicationRecord
  include AffectsStaffQueue
  belongs_to :character
  belongs_to :account
  belongs_to :reviewed_by, class_name: "Account", optional: true

  enum :status, { pending: "pending", approved: "approved", denied: "denied" }, validate: true

  validates :note, presence: true, unless: :claim
  validates :note, length: { maximum: 2_000 }
  validate :answers_are_filled_in, on: :create

  # Set when the game lets players claim roster characters straight away.
  attr_accessor :claim

  # The questions a game asks again when a character changes hands.
  def self.questions = ProfileField.where(ask_on_roster: true).ordered

  # The applicant's answers: { field_id => text }, only for roster questions.
  def answers=(values)
    ids = self.class.questions.pluck(:id).map(&:to_s)
    super(values.to_h.to_h { |id, text| [ id.to_s, text.to_s.strip.first(20_000) ] }.slice(*ids).compact_blank)
  end
  validate :character_is_on_the_roster, on: :create
  validate :one_at_a_time, on: :create

  def approve!(by:)
    transaction do
      character.lock!
      raise ActiveRecord::RecordNotFound, "#{character.name} is no longer on the roster" unless character.on_roster?
      character.take_over!(account, answers: answers)
      update!(status: "approved", reviewed_by: by, reviewed_at: Time.current)
      character.roster_applications.pending.where.not(id: id)
        .update_all(status: "denied", staff_reason: "Someone else was picked.", reviewed_by_id: by&.id, reviewed_at: Time.current)
    end
    NotificationMailer.application_decision(character).deliver_later if by && account.wants_email?
  end

  def deny!(by:, reason:)
    update!(status: "denied", staff_reason: reason.to_s.strip.first(250).presence, reviewed_by: by, reviewed_at: Time.current)
  end

  private
    def character_is_on_the_roster
      errors.add(:character, "isn't on the roster") unless character&.on_roster?
    end

    def answers_are_filled_in
      self.class.questions.where(required: true).each do |field|
        errors.add(:base, "#{field.name} needs an answer") if answers[field.id.to_s].blank?
      end
      self.class.questions.select(&:date?).each do |field|
        text = answers[field.id.to_s]
        errors.add(:base, "#{field.name} must be a date") if text.present? && !(Date.iso8601(text) rescue false)
      end
    end

    def one_at_a_time
      if RosterApplication.pending.exists?(character: character, account: account)
        errors.add(:base, "You've already applied for #{character.name}")
      end
    end
end
