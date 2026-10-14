# A one-way link from one room to another. Clicking it moves the active character.
# A Path can optionally point a compass direction (N, NNE ... NNW).
class Exit < ApplicationRecord
  # The 16 compass points, clockwise from north, with the words players see.
  DIRECTIONS = {
    "N" => "North", "NNE" => "North-northeast", "NE" => "Northeast", "ENE" => "East-northeast",
    "E" => "East", "ESE" => "East-southeast", "SE" => "Southeast", "SSE" => "South-southeast",
    "S" => "South", "SSW" => "South-southwest", "SW" => "Southwest", "WSW" => "West-southwest",
    "W" => "West", "WNW" => "West-northwest", "NW" => "Northwest", "NNW" => "North-northwest"
  }.freeze

  belongs_to :source_room, class_name: "Room"
  belongs_to :destination_room, class_name: "Room"

  normalizes :name, with: ->(n) { n.squish }
  normalizes :direction, with: ->(d) { d.strip.upcase.presence }

  # A Path with a direction but no name is named after the direction.
  before_validation { self.name = DIRECTIONS[direction] if name.blank? && direction }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { scope: :source_room_id }
  validates :direction, inclusion: { in: DIRECTIONS.keys }, uniqueness: { scope: :source_room_id }, allow_nil: true

  # Directions first, clockwise from north, then the rest by name.
  def self.in_compass_order(exits)
    exits.sort_by { |e| [ e.direction ? 0 : 1, compass_index(e.direction) || 0, e.name.downcase ] }
  end

  def self.compass_index(direction)
    DIRECTIONS.keys.index(direction)
  end

  def self.opposite(direction)
    direction && DIRECTIONS.keys[(compass_index(direction) + 8) % 16]
  end

  def direction_name
    DIRECTIONS[direction]
  end

  # Degrees clockwise from north, for drawing the compass.
  def angle
    direction && self.class.compass_index(direction) * 22.5
  end
end
