# What an item can do for rolls. It works like a SOUL Boon tied to one or
# more Skills, at a level, and its cost comes from that level. Staff make
# features; players can propose them for staff to approve.
class Crafting::Feature < ApplicationRecord
  STATUSES = %w[ approved proposed declined ].freeze

  belongs_to :proposed_by, class_name: "Character", optional: true

  normalizes :name, with: ->(name) { name.squish }
  validates :name, presence: true, length: { maximum: 60 }
  validates :name, uniqueness: { case_sensitive: false, conditions: -> { where(status: "approved") } }, if: :approved?
  validates :description, length: { maximum: 2000 }
  validates :decline_reason, length: { maximum: 300 }
  validates :level, inclusion: { in: Crafting::LEVELS }
  validates :status, inclusion: { in: STATUSES }
  validate :has_a_skill

  scope :ordered, -> { order(:name) }
  scope :approved, -> { where(status: "approved") }
  scope :proposed, -> { where(status: "proposed") }

  def approved? = status == "approved"
  def proposed? = status == "proposed"
  def cost = Crafting.feature_cost(level)
  def skills = Soul::Skill.where(id: skill_ids).order(:name)
  def fits?(item_type) = item_type_ids.empty? || item_type_ids.include?(item_type.id)
  def item_types = Crafting::ItemType.where(id: item_type_ids).ordered

  # "Minor Boon to Swordplay"
  def summary
    skill_names = Soul.enabled? ? skills.map(&:name) : []
    "#{level.capitalize} Boon#{" to #{skill_names.to_sentence}" if skill_names.any?}"
  end

  private
    def has_a_skill
      self.skill_ids = Array(skill_ids).compact_blank.map(&:to_i).uniq
      self.item_type_ids = Array(item_type_ids).compact_blank.map(&:to_i).uniq
      errors.add(:base, "Pick at least one Skill it helps.") if Soul.enabled? && skill_ids.empty?
    end
end
