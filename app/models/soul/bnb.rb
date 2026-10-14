# A Boon or Bane in the game's catalogue, such as Contacts or Cursed.
# Characters get their own copy (Soul::CharacterBnb) with a level, the
# Skills it affects and the player's private explanation.
class Soul::Bnb < ApplicationRecord
  has_many :character_bnbs, class_name: "Soul::CharacterBnb", foreign_key: :soul_bnb_id, dependent: :restrict_with_error, inverse_of: :bnb
  has_many :requests, class_name: "Soul::BnbRequest", foreign_key: :soul_bnb_id, dependent: :delete_all, inverse_of: :bnb

  enum :kind, { boon: "boon", bane: "bane" }, validate: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:kind, :name) }

  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 1_000 }

  def skills = Soul::Skill.where(id: skill_ids).ordered
  def label = "#{name} (#{kind.capitalize})"
end
