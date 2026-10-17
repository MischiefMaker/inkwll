# A ready-made item staff define, to sell in shops in Places and give as
# rewards. Buying or receiving one puts a copy in the character's
# Belongings.
class Crafting::CatalogueItem < ApplicationRecord
  has_one_attached :image
  has_many :shop_listings, class_name: "Crafting::ShopListing", dependent: :delete_all
  has_many :rooms, through: :shop_listings

  normalizes :name, with: ->(name) { name.squish }
  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 5000 }
  validates :price, numericality: { only_integer: true, in: 0..10_000_000 }
  validate :image_is_a_reasonable_picture

  scope :ordered, -> { order(:position, :name) }

  def features = Crafting::Feature.where(id: feature_ids).ordered

  # Puts a copy in a character's Belongings and logs it.
  def give_to!(character, kind:, quantity: 1, note: nil, actor: nil, other: nil)
    item = character.items.create!(name: name, description: description, quantity: quantity, catalogue_item: self, feature_ids: feature_ids)
    item.pictures.attach(image.blob) if image.attached?
    Crafting.log!(item, kind, character: character, other: other, note: note, actor: actor)
    item
  end

  private
    def image_is_a_reasonable_picture
      return unless image.attached? && attachment_changes["image"]
      errors.add(:image, "must be a picture (PNG, JPEG, GIF or WebP)") unless image.content_type.in?(Crafting::Item::IMAGE_TYPES)
      errors.add(:image, "must be smaller than 5 MB") if image.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
    end
end
