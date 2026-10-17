# A roll waiting for the Chapter's Storyteller, who sets the difficulty and
# rules on each Boon and Bane (must count, the player's choice, or doesn't
# count). It is then "ready" and the player picks their optional ones and rolls.
class Soul::PendingRoll < ApplicationRecord
  belongs_to :character
  belongs_to :scene
  belongs_to :skill, class_name: "Soul::Skill", foreign_key: :soul_skill_id

  belongs_to :judge, class_name: "Character", optional: true

  scope :in_progress, -> { where(status: %w[waiting ready]) }

  enum :status, { waiting: "waiting", ready: "ready", rolled: "rolled", cancelled: "cancelled" }, validate: true
end
