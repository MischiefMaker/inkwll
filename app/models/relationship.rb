# One of a character's relationships, written by their player: who, what
# kind, and a short note. The other side can be a character in the game
# (linked) or just a name, such as an NPC or someone offscreen.
class Relationship < ApplicationRecord
  KINDS = { "family" => "Family", "friend" => "Friend", "romance" => "Romance", "ally" => "Ally",
            "rival" => "Rival", "enemy" => "Enemy", "acquaintance" => "Acquaintance", "other" => "Other" }.freeze

  belongs_to :character
  belongs_to :other_character, class_name: "Character", optional: true

  attribute :other_character_name, :string

  before_validation :link_other_character

  validates :kind, inclusion: { in: KINDS.keys }
  validates :note, length: { maximum: 2_000 }
  validates :other_name, length: { maximum: 60 }
  validate :someone_named

  scope :ordered, -> { order(:position, :id) }

  def other_label
    other_character&.name || other_name
  end

  private
    # A name that matches a character in the game becomes a link to them.
    def link_other_character
      return if other_character_name.blank?
      name = other_character_name.squish
      self.other_character = Character.where("lower(name) = ?", name.downcase).where.not(id: character_id).first
      self.other_name = other_character ? nil : name
    end

    def someone_named
      errors.add(:base, "Name who the relationship is with") if other_character.nil? && other_name.blank?
    end
end
