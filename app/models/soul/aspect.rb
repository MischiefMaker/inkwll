# One of SOUL's Aspects, such as Body, Mind or Spirit. Each Skill belongs to
# one, and a character's Aspect rating adds a little to rolls of its Skills.
class Soul::Aspect < ApplicationRecord
  has_many :skills, -> { order(:position, :name) }, class_name: "Soul::Skill", foreign_key: :soul_aspect_id,
    inverse_of: :aspect, dependent: :restrict_with_error
  has_many :ratings, as: :trait, class_name: "Soul::Rating", dependent: :destroy

  scope :ordered, -> { order(:position, :name) }

  before_validation { self.key = name.to_s.parameterize(separator: "_") if key.blank? }
  validates :name, presence: true, length: { maximum: 40 }
  validates :key, presence: true, uniqueness: true
  validates :description, length: { maximum: 200 }

  def aspect? = true
  def max_rating = Soul::Rules.aspect_max
end
