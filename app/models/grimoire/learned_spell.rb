# A spell a character has learned, and what it cost.
class Grimoire::LearnedSpell < ApplicationRecord
  belongs_to :character
  belongs_to :spell, class_name: "Grimoire::Spell"
  validates :spell_id, uniqueness: { scope: :character_id }
end
