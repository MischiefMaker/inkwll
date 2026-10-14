# For things that can be described with an image, text, or both (Areas and
# Settings). Pages show whichever the builder filled in.
module DescribedWithImage
  extend ActiveSupport::Concern

  MAX_IMAGE_SIZE = 5.megabytes

  included do
    has_one_attached :image
    attribute :remove_image, :boolean, default: false

    validate :image_is_a_reasonable_picture
    after_save { image.purge_later if remove_image && image.attached? }
  end

  private
    def image_is_a_reasonable_picture
      return unless image.attached? && attachment_changes["image"]
      errors.add(:image, "must be a picture (PNG, JPEG, GIF or WebP)") unless image.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
      errors.add(:image, "must be smaller than 5 MB") if image.blob.byte_size > MAX_IMAGE_SIZE
    end
end
