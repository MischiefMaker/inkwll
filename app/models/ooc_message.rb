# A message in the site-wide out-of-character chat. Shown under the player's
# display name, never a character name. Guests (people not logged in) can
# chat too, under a name they pick, shown with "(guest)".
#
# Players can edit and delete their own messages, and staff anyone's. An
# edited message says "(edited)"; a deleted one stays in place as "Deleted"
# or "Removed by staff" (owner). The words are kept for staff's records.
class OocMessage < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :removed_by, class_name: "Account", optional: true

  validates :body, presence: true, length: { maximum: 1000 }
  validates :guest_name, presence: true, unless: :account
  validate :guests_cannot_post_links, unless: :account

  scope :recent, -> { order(created_at: :desc, id: :desc).limit(50) }
  scope :from_guests, -> { where(account_id: nil) }

  after_create_commit -> { broadcast_append_to :ooc_chat, target: "ooc_messages" }
  after_update_commit -> { broadcast_replace_to :ooc_chat }
  after_destroy_commit -> { broadcast_remove_to :ooc_chat }

  def guest?
    account_id.nil?
  end

  def author_name
    guest? ? "#{guest_name} (guest)" : account.display_name
  end

  def deleted?
    deleted_at.present?
  end

  def removed_by_staff?
    removed_by_id.present? && removed_by_id != account_id
  end

  # The author can change their own message; staff can change anyone's.
  def changeable_by?(someone)
    someone.present? && !deleted? && (someone == account || someone.staff?)
  end

  def edit_by(someone, new_body)
    update(body: new_body, edited_at: Time.current, edited_by_staff: edited_by_staff? || someone != account)
  end

  def delete_by(someone)
    update_columns(deleted_at: Time.current, removed_by_id: someone.id, updated_at: Time.current)
    broadcast_replace_to :ooc_chat
  end

  private
    # Links are what spammers come for, so guests can't post them.
    def guests_cannot_post_links
      errors.add(:base, "Guests can't post links. Make an account to share one") if body.to_s.match?(%r{https?://|www\.|\.(com|net|org|ru|xyz|top)\b}i)
    end
end
