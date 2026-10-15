# What a character's player wrote in one profile field.
class ProfileValue < ApplicationRecord
  belongs_to :character
  belongs_to :profile_field
  # The answer to a Picture field. Its value holds the file name, so the
  # usual "is it filled in?" checks still work.
  has_one_attached :image

  validates :value, length: { maximum: 20_000 }
  validate :dates_are_dates
  validate :image_is_a_reasonable_picture

  def as_date
    Date.iso8601(value) if value.present?
  rescue Date::Error
    nil
  end

  # Replaces the picture, or with nil removes it.
  def picture=(file)
    if file
      self.image = file
      self.value = file.original_filename.to_s.last(200).presence || "picture"
    else
      image.purge_later if image.attached?
      self.value = nil
    end
  end

  private
    # Same rules as other pictures (see DescribedWithImage).
    def image_is_a_reasonable_picture
      return unless image.attached? && attachment_changes["image"]
      errors.add(:image, "for #{profile_field.name} must be a picture (PNG, JPEG, GIF or WebP)") unless image.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
      errors.add(:image, "for #{profile_field.name} must be smaller than 5 MB") if image.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
    end

    def dates_are_dates
      errors.add(:value, "for #{profile_field.name} must be a date") if profile_field.date? && value.present? && as_date.nil?
    end
end
