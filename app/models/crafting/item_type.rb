# Something characters can make, with its starting cost and the SOUL Skill
# used to make it: a sword (40 crowns, Smithing).
class Crafting::ItemType < ApplicationRecord
  belongs_to :skill, class_name: "Soul::Skill", foreign_key: :soul_skill_id, optional: true
  has_many :items, class_name: "Crafting::Item", dependent: :nullify

  normalizes :name, with: ->(name) { name.squish }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 2000 }
  validates :base_cost, numericality: { only_integer: true, in: 0..10_000_000 }

  scope :ordered, -> { order(:position, :name) }

  def features = Crafting::Feature.approved.ordered.select { |feature| feature.fits?(self) }
end
