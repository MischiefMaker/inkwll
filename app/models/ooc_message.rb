# A message in the site-wide out-of-character chat. Shown under the player's
# display name, never a character name. Guests (people not logged in) can
# chat too, under a name they pick, shown with "(guest)".
class OocMessage < ApplicationRecord
  belongs_to :account, optional: true

  validates :body, presence: true, length: { maximum: 1000 }
  validates :guest_name, presence: true, unless: :account
  validate :guests_cannot_post_links, unless: :account

  scope :recent, -> { order(created_at: :desc, id: :desc).limit(50) }
  scope :from_guests, -> { where(account_id: nil) }

  after_create_commit -> { broadcast_append_to :ooc_chat, target: "ooc_messages" }
  after_destroy_commit -> { broadcast_remove_to :ooc_chat }

  def guest?
    account_id.nil?
  end

  def author_name
    guest? ? "#{guest_name} (guest)" : account.display_name
  end

  private
    # Links are what spammers come for, so guests can't post them.
    def guests_cannot_post_links
      errors.add(:base, "Guests can't post links. Make an account to share one") if body.to_s.match?(%r{https?://|www\.|\.(com|net|org|ru|xyz|top)\b}i)
    end
end
