# Another game (Well) on the Founder's droplet, started from the Wells page.
# Its database, passwords and uploads are its own; this row only remembers
# where it lives and which version it runs. See docs/wells.md.
class Well < ApplicationRecord
  belongs_to :account
  has_many :well_updates, dependent: :destroy

  STATUSES = %w[ starting live failed ].freeze

  normalizes :slug, :domain, with: ->(value) { value.to_s.strip.downcase }

  validates :name, presence: true, length: { maximum: 60 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9]{1,19}\z/, message: "must be 2 to 20 small letters and numbers, starting with a letter" },
    exclusion: { in: %w[ inkwll www mail ], message: "is already taken" }
  validates :domain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+(\.[a-z0-9-]+)+\z/, message: "doesn't look like an address" }
  validate :not_this_game

  before_validation { self.setup_code ||= SecureRandom.hex(16) }

  scope :listed, -> { order(:created_at) }

  # Where its first player signs up to become its Founder. It only works
  # until that Well has a Founder.
  def setup_url = "https://#{domain}/registration/new?setup=#{setup_code}"

  private
    def not_this_game
      errors.add(:domain, "is this game's own address") if domain.present? && domain.in?([ ENV["APP_HOST"], "inkwll.com" ].compact)
    end
end
