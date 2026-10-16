# A one-way link from one room to another. Clicking it moves the active character.
#
# Every Path has a kind (owner, 2026-10-14):
#   street    the ordinary way between places; can point a compass direction
#   building  something to go into from here, like a shop door
#   unit      one of many numbered doors, like apartments: a Path with a door
#             number ("100") is a unit, shown in the Setting's compact
#             numbered list
# and can have a direction: one of the 16 compass points (streets only), or
# Out, the usual way back from inside a building.
class Exit < ApplicationRecord
  # The 16 compass points, clockwise from north, with the words players see.
  COMPASS = {
    "N" => "North", "NNE" => "North-northeast", "NE" => "Northeast", "ENE" => "East-northeast",
    "E" => "East", "ESE" => "East-southeast", "SE" => "Southeast", "SSE" => "South-southeast",
    "S" => "South", "SSW" => "South-southwest", "SW" => "Southwest", "WSW" => "West-southwest",
    "W" => "West", "WNW" => "West-northwest", "NW" => "Northwest", "NNW" => "North-northwest"
  }.freeze
  DIRECTIONS = COMPASS.merge("OUT" => "Out").freeze
  KINDS = %w[ street building unit ].freeze

  # How a room's Paths are grouped: Streets first (they make up the map),
  # then the rest by the type of Place they lead to.
  PATH_GROUPS = { "street" => "Streets", "building" => "Buildings", "outdoor" => "Outdoor areas", "other" => "Other places" }.freeze

  belongs_to :source_room, class_name: "Room"
  belongs_to :destination_room, class_name: "Room"

  normalizes :name, with: ->(n) { n.squish }
  normalizes :direction, with: ->(d) { d.strip.upcase.presence }
  normalizes :number, with: ->(n) { n.strip.presence }

  # A Path with a direction but no name is named after the direction, and a
  # Path with a door number is a unit.
  before_validation { self.name = DIRECTIONS[direction] if name.blank? && direction }
  before_validation { self.kind = "unit" if number }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { scope: :source_room_id }
  validates :kind, inclusion: { in: KINDS }

  # The kind a new Path gets from the Place it leads to: a building (with or
  # without units) is entered, so it's a Building; anything else is an
  # ordinary Street. A door number makes it a Unit regardless.
  def self.kind_for(room)
    room&.kind.in?(%w[ apartments building ]) ? "building" : "street"
  end

  def path_group
    return "street" if kind == "street"
    case destination_room.kind
    when "apartments", "building" then "building"
    when "outdoor" then "outdoor"
    else "other"
    end
  end
  validates :direction, inclusion: { in: DIRECTIONS.keys }, uniqueness: { scope: :source_room_id }, allow_nil: true
  validates :number, length: { maximum: 10 }, format: { with: /\A[A-Za-z0-9.\-]+\z/, message: "can only use letters, numbers, dots and dashes" },
    uniqueness: { scope: :source_room_id }, allow_nil: true

  scope :numbered, -> { where.not(number: nil) }
  scope :unnumbered, -> { where(number: nil) }
  validate :compass_directions_are_for_streets

  scope :streets, -> { where(kind: "street") }

  # Out first, then compass directions clockwise from north, then the rest by name.
  def self.in_compass_order(exits)
    exits.sort_by { |e| [ e.direction == "OUT" ? 0 : (e.compass? ? 1 : 2), compass_index(e.direction) || 0, e.name.downcase ] }
  end

  # Door numbers in counting order (2 before 10, 101 before 101A).
  def self.in_number_order(exits)
    exits.sort_by { |e| [ e.number.to_i, e.number.downcase, e.name.downcase ] }
  end

  def self.compass_index(direction)
    COMPASS.keys.index(direction)
  end

  # The way back: a Path north comes back south. Buildings and units come
  # back Out.
  def self.opposite(direction, kind: "street")
    return "OUT" unless kind == "street"
    direction && compass_index(direction) && COMPASS.keys[(compass_index(direction) + 8) % 16]
  end

  def compass?
    COMPASS.key?(direction)
  end

  def direction_name
    DIRECTIONS[direction]
  end

  private
    def compass_directions_are_for_streets
      errors.add(:direction, "can only be a compass point on a street") if compass? && kind != "street"
      errors.add(:number, "is needed for a unit") if kind == "unit" && number.nil?
    end
end
