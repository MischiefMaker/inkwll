# A one-way link from one room to another. Clicking it moves the active character.
class Exit < ApplicationRecord
  belongs_to :source_room, class_name: "Room"
  belongs_to :destination_room, class_name: "Room"

  normalizes :name, with: ->(n) { n.squish }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { scope: :source_room_id }
end
