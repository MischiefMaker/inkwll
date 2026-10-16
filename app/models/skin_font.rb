# A web font that came with a game's world pack: one WOFF2 file for one
# family, weight and style. The game's skin stylesheet declares it
# (GameSetting::Skin#skin_css), so the family can be named in Admin → Look.
# Fonts are served from the game itself because the content security policy
# doesn't let pages load fonts from other sites.
class SkinFont < ApplicationRecord
  MAX_SIZE = 300.kilobytes
  CONTENT_TYPE = "font/woff2"
  WEIGHTS = (1..9).map { |n| n * 100 }.freeze
  STYLES = %w[ normal italic ].freeze

  belongs_to :game_setting
  has_one_attached :file

  # Letters, numbers, spaces and hyphens only, so nothing else can be
  # slipped into the stylesheet.
  normalizes :family, with: ->(family) { family.squish }
  validates :family, presence: true, length: { maximum: 60 }, format: { with: /\A[\p{L}\p{N} -]+\z/, message: "can only have letters, numbers, spaces and hyphens" }
  validates :weight, inclusion: { in: WEIGHTS }
  validates :style, inclusion: { in: STYLES }
  validates :family, uniqueness: { scope: %i[ game_setting_id weight style ] }
  validate :file_is_a_font

  def name
    [ family, (weight unless weight == 400), (style unless style == "normal") ].compact.join(" ")
  end

  def font_face
    url = Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
    %(@font-face { font-family: "#{family}"; src: url("#{url}") format("woff2"); font-weight: #{weight}; font-style: #{style}; font-display: swap; })
  end

  private
    def file_is_a_font
      return errors.add(:file, "is missing") unless file.attached?
      errors.add(:file, "must be a WOFF2 font") unless file.content_type == CONTENT_TYPE
      errors.add(:file, "must be smaller than #{MAX_SIZE / 1.kilobyte} KB") if file.blob.byte_size > MAX_SIZE
    end
end
