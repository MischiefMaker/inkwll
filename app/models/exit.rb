# A one-way link from one room to another. Clicking it moves the active character.
# A Path can optionally point a compass direction (N, NNE ... NNW), or carry a
# door number ("100"), which puts it in the Setting's compact numbered list.
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
  normalizes :number, with: ->(n) { n.strip.presence }

  # A Path with a direction but no name is named after the direction.
  before_validation { self.name = DIRECTIONS[direction] if name.blank? && direction }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { scope: :source_room_id }
  validates :direction, inclusion: { in: DIRECTIONS.keys }, uniqueness: { scope: :source_room_id }, allow_nil: true
  validates :number, length: { maximum: 10 }, format: { with: /\A[A-Za-z0-9.\-]+\z/, message: "can only use letters, numbers, dots and dashes" },
    uniqueness: { scope: :source_room_id }, allow_nil: true

  scope :numbered, -> { where.not(number: nil) }
  scope :unnumbered, -> { where(number: nil) }

  # Directions first, clockwise from north, then the rest by name.
  def self.in_compass_order(exits)
    exits.sort_by { |e| [ e.direction ? 0 : 1, compass_index(e.direction) || 0, e.name.downcase ] }
  end

  # Door numbers in counting order (2 before 10, 101 before 101A).
  def self.in_number_order(exits)
    exits.sort_by { |e| [ e.number.to_i, e.number.downcase, e.name.downcase ] }
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
