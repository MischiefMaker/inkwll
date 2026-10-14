# A Setting a player has saved to "My places", to travel back to in one click.
class SavedPlace < ApplicationRecord
  belongs_to :account
  belongs_to :room

  validates :room_id, uniqueness: { scope: :account_id }
end
