# A character's rating in one Aspect or Skill.
class Soul::Rating < ApplicationRecord
  belongs_to :character
  belongs_to :trait, polymorphic: true

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
