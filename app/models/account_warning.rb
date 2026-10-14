# A warning from staff to a player. It shows at the top of every page until
# the player reads it.
class AccountWarning < ApplicationRecord
  belongs_to :account
  belongs_to :staff, class_name: "Account"
  belongs_to :report, optional: true

  validates :body, presence: true, length: { maximum: 5_000 }

  scope :unread, -> { where(read_at: nil) }
end
