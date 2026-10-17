# A small map of the Streets around a Place, drawn on the Place's page.
#
# Only Streets go on the map: Places of the Street type joined by Street
# Paths that point a compass direction. From the street you're on (or, inside
# a building, the street with a Path into it) the map walks out up to RADIUS
# streets, setting each one a step away in its Path's direction. When you're
# on a street, its buildings and other places are listed with it.
class MiniMap
  RADIUS = 3
  MAX_STREETS = 30

  Spot = Struct.new(:room, :x, :y, :current, keyword_init: true)

  attr_reader :spots, :lines, :centre, :places

  def self.for(room)
    return unless GameSetting.current.mini_map_enabled?
    map = new(room)
    map if map.spots.size > 1
  end

  def initialize(room)
    @room = room
    @centre = room.kind == "street" ? room : street_beside(room)
    @spots = []
    @lines = []
    @places = []
    return unless @centre

    walk
    @places = room.exits.includes(:destination_room).reject { |e| e.kind == "street" }.sort_by { |e| [ e.number.to_s, e.name ] } if room == @centre
  end

  def on_street?
    @room == @centre
  end

  # The box the spots sit in, as an SVG viewBox with room around the edges.
  # Streets sit wider apart across than down, so names side by side fit.
  def view_box(scale_x:, scale_y:, margin:)
    xs = spots.map(&:x)
    ys = spots.map(&:y)
    left = xs.min * scale_x - margin * 1.5
    top = ys.min * scale_y - margin
    [ left, top, (xs.max - xs.min) * scale_x + margin * 3, (ys.max - ys.min) * scale_y + margin * 2 ].map { |n| n.round(1) }.join(" ")
  end

  private
    def street_beside(room)
      Room.where(kind: "street", id: Exit.where(destination_room_id: room.id).select(:source_room_id)).order(:name).first
    end

    # Breadth-first out from the centre, so nearer streets win any spot that
    # two streets would share.
    def walk
      placed = { @centre.id => add_spot(@centre, 0.0, 0.0) }
      taken = { [ 0.0, 0.0 ] => true }
      queue = [ [ @centre, 0 ] ]
      seen_lines = {}
      until queue.empty? || placed.size >= MAX_STREETS
        room, depth = queue.shift
        next if depth >= RADIUS
        street_exits_from(room).each do |exit|
          other = exit.destination_room
          from = placed[room.id]
          if (to = placed[other.id])
            add_line(from, to, seen_lines)
            next
          end
          free = free_spot(from, exit.direction, taken) or next
          x, y = free
          spot = add_spot(other, x, y)
          placed[other.id] = spot
          taken[[ x, y ]] = true
          add_line(from, spot, seen_lines)
          queue << [ other, depth + 1 ]
        end
      end
    end

    def street_exits_from(room)
      room.exits.includes(:destination_room).select do |exit|
        exit.kind == "street" && exit.compass? && exit.destination_room.kind == "street"
      end.sort_by { |exit| Exit.compass_index(exit.direction) }
    end

    # A step in the Path's direction; if that spot is taken, a step further.
    def free_spot(from, direction, taken)
      angle = Exit.compass_index(direction) * 22.5 * Math::PI / 180
      [ 1, 1.6, 2.2 ].each do |step|
        x = (from.x + Math.sin(angle) * step).round(1)
        y = (from.y - Math.cos(angle) * step).round(1)
        return [ x, y ] unless taken.keys.any? { |tx, ty| (tx - x).abs < 0.6 && (ty - y).abs < 0.6 }
      end
      nil
    end

    def add_spot(room, x, y)
      Spot.new(room: room, x: x, y: y, current: room == @room).tap { |spot| @spots << spot }
    end

    def add_line(from, to, seen)
      key = [ from.room.id, to.room.id ].sort
      return if seen[key]
      seen[key] = true
      @lines << [ from, to ]
    end
end
