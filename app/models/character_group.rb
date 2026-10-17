# A group a game sorts characters into, such as a house or faction. Each
# group has a colour that colours its characters' names.
class CharacterGroup < ApplicationRecord
  has_many :characters, dependent: :nullify

  normalizes :name, with: ->(n) { n.squish }
  normalizes :colour, with: ->(c) { c.strip.downcase }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :colour, format: { with: /\A#\h{6}\z/, message: "must be a colour like #5b3f8c" }
  validates :description, length: { maximum: 300 }
  normalizes :wanted_note, with: ->(n) { n.squish.presence }
  validates :wanted_note, length: { maximum: 200 }

  scope :ordered, -> { order(:position, :name) }
end
