# A roll waiting for the Chapter's Storyteller, who sets the difficulty and
# decides which Boons and Banes count before it's rolled.
class Soul::PendingRoll < ApplicationRecord
  belongs_to :character
  belongs_to :scene
  belongs_to :skill, class_name: "Soul::Skill", foreign_key: :soul_skill_id

  enum :status, { waiting: "waiting", rolled: "rolled", cancelled: "cancelled" }, validate: true
end
