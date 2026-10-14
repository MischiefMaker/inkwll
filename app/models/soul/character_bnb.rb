# One of a character's Boons or Banes. It changes rolls of the Skills it's
# tied to, by its level. Resolving it (instead of deleting) keeps it on
# record and stops it counting; staff can restore it.
class Soul::CharacterBnb < ApplicationRecord
  belongs_to :character
  belongs_to :bnb, class_name: "Soul::Bnb", foreign_key: :soul_bnb_id, inverse_of: :character_bnbs

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :ordered, -> { joins(:bnb).order("soul_bnbs.kind", "soul_bnbs.name") }

  validates :level, inclusion: { in: ->(_) { Soul::Rules.bnb_levels.keys } }
  validates :explanation, length: { maximum: 2_000 }
  validate :has_skills

  delegate :boon?, :bane?, :name, :kind, to: :bnb

  def resolved? = resolved_at.present?
  def skills = Soul::Skill.where(id: skill_ids).ordered
  def modifier = Soul::Rules.bnb_levels.fetch(level, 0) * (boon? ? 1 : -1)
  def affects?(skill) = !resolved? && skill_ids.include?(skill.id)

  private
    def has_skills
      errors.add(:base, "Pick at least one Skill it affects") if skill_ids.blank?
    end
end
