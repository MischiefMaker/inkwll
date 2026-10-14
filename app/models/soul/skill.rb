# One of SOUL's Skills. Rolls are made with a Skill: its rating plus a bonus
# from its Aspect.
class Soul::Skill < ApplicationRecord
  belongs_to :aspect, class_name: "Soul::Aspect", foreign_key: :soul_aspect_id, inverse_of: :skills
  has_many :ratings, as: :trait, class_name: "Soul::Rating", dependent: :destroy

  scope :ordered, -> { order(:position, :name) }

  before_validation { self.key = name.to_s.parameterize(separator: "_") if key.blank? }
  validates :name, presence: true, length: { maximum: 40 }
  validates :key, presence: true, uniqueness: true
  validates :description, length: { maximum: 200 }

  def aspect? = false
  def max_rating = Soul::Rules.skill_max
end
