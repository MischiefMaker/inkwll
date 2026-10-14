# A school of magic, tied to the SOUL Skill used to learn and cast its spells.
class Grimoire::Branch < ApplicationRecord
  belongs_to :skill, class_name: "Soul::Skill", foreign_key: :soul_skill_id
  has_many :spells, class_name: "Grimoire::Spell", dependent: :restrict_with_error

  normalizes :name, with: ->(n) { n.squish }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 2_000 }

  scope :ordered, -> { order(:position, :name) }
end
