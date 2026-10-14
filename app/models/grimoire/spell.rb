# A spell in a branch. Learning it needs a rating of at least
# minimum_rating in the branch's Skill; casting it rolls that Skill against
# the spell's SOUL difficulty. Spells are retired, not deleted, so
# characters who learned one keep it on record.
class Grimoire::Spell < ApplicationRecord
  belongs_to :branch, class_name: "Grimoire::Branch"
  belongs_to :created_by, class_name: "Account", optional: true
  has_many :learned_spells, class_name: "Grimoire::LearnedSpell", dependent: :restrict_with_error

  normalizes :name, with: ->(n) { n.squish }
  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { scope: :branch_id, case_sensitive: false }
  validates :description, length: { maximum: 5_000 }
  validates :minimum_rating, numericality: { only_integer: true, in: 0..20 }
  validates :difficulty_name, inclusion: { in: ->(_) { Soul::Rules.difficulties.keys } }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:minimum_rating, :name) }

  def xp_cost = minimum_rating * Grimoire.xp_cost_per_rating
  def difficulty = Soul::Rules.difficulties.fetch(difficulty_name)
  def difficulty_label = "#{difficulty_name.humanize} (#{difficulty})"
end
