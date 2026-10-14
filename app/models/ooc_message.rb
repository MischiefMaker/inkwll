# A message in the site-wide out-of-character chat. Shown under the player's
# display name, never a character name.
class OocMessage < ApplicationRecord
  belongs_to :account

  validates :body, presence: true, length: { maximum: 1000 }

  scope :recent, -> { order(created_at: :desc, id: :desc).limit(50) }

  after_create_commit -> { broadcast_append_to :ooc_chat, target: "ooc_messages" }
end
