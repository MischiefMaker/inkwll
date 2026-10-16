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

  # How the Well is asked whether it has a Founder; tests swap it out.
  class_attribute :founder_check, default: ->(domain) do
    response = Net::HTTP.start(domain, 443, use_ssl: true, open_timeout: 3, read_timeout: 3) { |http| http.get("/well_status") }
    response.is_a?(Net::HTTPSuccess) && JSON.parse(response.body)["founder"] == true
  end

  # Where its first player signs up to become its Founder. It only works
  # until that Well has a Founder.
  # With copy_founder, the form opens with the creator's name and email filled
  # in; they only choose a password. No password ever leaves the game.
  def setup_url
    query = { setup: setup_code }
    query.merge!(name: account.display_name, email: account.email) if copy_founder?
    query[:import] = 1 if import_world?
    "https://#{domain}/registration/new?#{query.to_query}"
  end

  # Where the Founder of this Well uploads a world pack (see WorldPack).
  def import_url = "https://#{domain}/admin/world_import"

  # The first sign-up link is shown while the Well is running and has no
  # Founder yet.
  def setup_link_open? = status == "live" && founder_claimed_at.nil?

  # Asks the Well whether its Founder has signed up. A Well that doesn't answer
  # yet (still starting, or on an older version) keeps its link.
  def check_founder!
    return unless setup_link_open?
    update!(founder_claimed_at: Time.current) if founder_check.call(domain)
  rescue StandardError
    nil
  end

  private
    def not_this_game
      errors.add(:domain, "is this game's own address") if domain.present? && domain.in?([ ENV["APP_HOST"], "inkwll.com" ].compact)
    end
end
