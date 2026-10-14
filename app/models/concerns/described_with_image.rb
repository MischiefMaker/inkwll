# For things builders can dress up (Areas and Settings). Every part is
# optional and pages show whichever the builder filled in:
#   icon        a small picture shown beside the name in lists
#   image       the large banner across the top of its page
#   background  a picture behind its whole page
#   summary     a line or two of short text, shown in lists
#   description the long text, shown on its own page
module DescribedWithImage
  extend ActiveSupport::Concern

  MAX_IMAGE_SIZE = 5.megabytes
  PICTURES = %i[ icon image background ].freeze

  included do
    PICTURES.each do |picture|
      has_one_attached picture
      attribute :"remove_#{picture}", :boolean, default: false
      after_save { send(picture).purge_later if send(:"remove_#{picture}") && send(picture).attached? }
    end

    normalizes :summary, with: ->(text) { text.squish.presence }
    validates :summary, length: { maximum: 200 }
    validate :pictures_are_reasonable
  end

  private
    def pictures_are_reasonable
      PICTURES.each do |picture|
        file = send(picture)
        next unless file.attached? && attachment_changes[picture.to_s]
        errors.add(picture, "must be a picture (PNG, JPEG, GIF or WebP)") unless file.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
        errors.add(picture, "must be smaller than 5 MB") if file.blob.byte_size > MAX_IMAGE_SIZE
      end
    end
end
