# A recurring non-player character that staff keep for the game (the shared
# NPC list). Anyone running a Chapter can pick one for an NPC Passage, which
# then shows its name and picture. NPCs are never anyone's character: they
# don't appear in My Characters, the directory, Where or Here.
#
# The description is public, on the NPCs page. Notes and SOUL ratings are for
# staff and Storytellers only.
class Npc < ApplicationRecord
  has_one_attached :icon
  attribute :remove_icon, :boolean, default: false
  has_many :poses, dependent: :nullify

  normalizes :name, with: ->(n) { n.squish }
  normalizes :description, :notes, with: ->(text) { text.strip.presence }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :description, :notes, length: { maximum: 3_000 }
  validate :icon_is_a_reasonable_picture

  after_save { icon.purge_later if remove_icon && icon.attached? }

  scope :ordered, -> { order(:name) }

  # NPCs aren't GM stand-ins; this lets them share the character picture helper.
  def gm? = false

  # Who may read the notes and ratings: staff and Storytellers.
  def self.secrets_for?(account) = account.present? && account.may_storytell?

  # { Soul::Skill => rating } for the skills it has a rating in.
  def skill_ratings
    ids = soul_ratings.transform_keys(&:to_i)
    Soul::Skill.where(id: ids.keys).includes(:aspect).order(:name).map { |skill| [ skill, ids[skill.id].to_i ] }
  end

  def soul_ratings=(ratings)
    super(ratings.to_h.transform_keys(&:to_s).transform_values { |value| value.to_s.strip }.reject { |_, value| value.blank? }
      .transform_values { |value| value.to_i.clamp(0, Soul::Rules.skill_max) })
  end

  private
    def icon_is_a_reasonable_picture
      return unless icon.attached? && attachment_changes["icon"]
      errors.add(:icon, "must be a picture (PNG, JPEG, GIF or WebP)") unless icon.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
      errors.add(:icon, "must be smaller than 5 MB") if icon.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
    end
end
