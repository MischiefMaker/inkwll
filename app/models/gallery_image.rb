# A picture in a character's gallery, with an optional caption. GIFs welcome.
class GalleryImage < ApplicationRecord
  MAX_PER_CHARACTER = 30
  # All of one player's characters together.
  MAX_PER_PLAYER = 50

  belongs_to :character
  has_one_attached :image

  validates :caption, length: { maximum: 200 }
  validate :image_is_a_reasonable_picture
  validate :not_too_many, on: :create

  scope :ordered, -> { order(:position, :id) }

  private
    def image_is_a_reasonable_picture
      if !image.attached?
        errors.add(:image, "is needed")
      elsif attachment_changes["image"]
        errors.add(:image, "must be a picture (PNG, JPEG, GIF or WebP)") unless image.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
        errors.add(:image, "must be smaller than 5 MB") if image.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
      end
    end

    def not_too_many
      errors.add(:base, "A gallery can hold up to #{MAX_PER_CHARACTER} pictures") if character && character.gallery_images.count >= MAX_PER_CHARACTER
      if character && GalleryImage.joins(:character).where(characters: { account_id: character.account_id }).count >= MAX_PER_PLAYER
        errors.add(:base, "Your characters can have up to #{MAX_PER_PLAYER} gallery pictures between them")
      end
    end
end
