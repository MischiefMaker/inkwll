# A line in a character's Narrative History: a plain-language record of
# how they've changed, for the player and staff.
class Soul::HistoryEntry < ApplicationRecord
  belongs_to :character
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
end
