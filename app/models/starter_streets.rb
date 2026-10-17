# The streets of the sample map: one street, lane or path in each smaller Area,
# with that Area's buildings and outdoor spaces on it. New games get them from
# db/seeds.rb; a game that was started before they existed can have them added
# with StarterStreets.install! (the migration that did this ran it once).
#
# It only touches the sample map: a street is added to an Area only when the
# Area and both of its sample Places are still there, and it never overwrites
# or deletes anything. Running it again does nothing.
module StarterStreets
  STREETS = [
    { area: "Uptown", name: "Uptown Street", description: <<~TEXT.squish,
      A broad street of pale stone terraces, wrought-iron railings and the occasional liveried chauffeur waiting at the kerb. Uptown Street is the way through the quiet, wealthy part of the city, with the Ashcombe Hotel's striped awning halfway along and the leafy sweep of Grand Avenue opening off it. The street runs south toward Midtown, the traffic thickening as it goes.
    TEXT
      places: [ [ "Ashcombe Hotel", "The Ashcombe Hotel", "building" ], [ "Grand Avenue", "Grand Avenue", "outdoor" ] ], was_entered_at: "Grand Avenue" },
    { area: "Midtown", name: "Midtown Street", description: <<~TEXT.squish,
      Buses, bicycles and a river of people on foot, all in a hurry. Midtown Street is the city's main artery, lined with shopfronts, offices and food carts, and it passes the great open space of Central Square with the glowing windows of the Lamplight Café just beyond. North, the street climbs toward Uptown; south, it dips toward the noise of Downtown.
    TEXT
      places: [ [ "Central Square", "Central Square", "outdoor" ], [ "Lamplight Café", "The Lamplight Café", "building" ] ], was_entered_at: "Central Square" },
    { area: "Downtown", name: "Downtown Street", description: <<~TEXT.squish,
      Cracked paving, tram wires overhead and shuttered shopfronts that open only when it suits them. Downtown Street is the gritty way through the old part of the city, with the soot-streaked bulk of Union Station on one side and the cobbled lanes of Harbour Market leading off toward the water. It runs north toward Midtown and the cleaner streets beyond.
    TEXT
      places: [ [ "Union Station", "Union Station", "building" ], [ "Harbour Market", "Harbour Market", "outdoor" ] ], was_entered_at: "Union Station" },
    { area: "The Village", name: "High Street", description: <<~TEXT.squish,
      The village's one proper street, a crooked ribbon of cobbles between cottages that lean toward each other like gossips. High Street runs from the church to the Crooked Kettle and the green, and on to the lane that leads out toward the farms.
    TEXT
      places: [ [ "Village Green", "Village Green", "outdoor" ], [ "Crooked Kettle", "The Crooked Kettle", "building" ] ], was_entered_at: "Village Green" },
    { area: "Farmland", name: "Hedgerow Lane", description: <<~TEXT.squish,
      A narrow lane between high hedges, rutted by cart wheels and muddy for most of the year. Hedgerow Lane wanders past the gates of every farm in the valley, with Farm Lane and the Hay Barn off it, and carries on toward the river.
    TEXT
      places: [ [ "Farm Lane", "Farm Lane", "outdoor" ], [ "Hay Barn", "The Hay Barn", "building" ] ], was_entered_at: "Farm Lane" },
    { area: "Riverside", name: "The Towpath", description: <<~TEXT.squish,
      A grassy path trodden hard by horses and walkers, following the river through the willows. The Towpath links the old Stone Bridge and the quiet Riverbank, and the lane back up to the farms meets it near the bridge.
    TEXT
      places: [ [ "Stone Bridge", "The Stone Bridge", "outdoor" ], [ "Riverbank", "The Riverbank", "outdoor" ] ], was_entered_at: "The Stone Bridge" },
    { area: "Forest's Edge", name: "Woodland Track", description: <<~TEXT.squish,
      A wide, rutted track where the last fields give way to trees. Woodland Track runs along the forest's edge, past the Trailhead and the Ranger's Cabin, before narrowing and plunging in among the oaks.
    TEXT
      places: [ [ "Trailhead", "The Trailhead", "outdoor" ], [ "Ranger's Cabin", "The Ranger's Cabin", "building" ] ], was_entered_at: "The Trailhead" },
    { area: "Deep Woods", name: "Mossy Path", description: <<~TEXT.squish,
      A narrow, winding path, soft underfoot with moss and old leaves, where the light comes down green and dim. The Mossy Path threads between the trees to Old Oak Clearing and Fern Hollow, and one branch leads on down toward the lake.
    TEXT
      places: [ [ "Old Oak Clearing", "Old Oak Clearing", "outdoor" ], [ "Fern Hollow", "Fern Hollow", "outdoor" ] ], was_entered_at: "Old Oak Clearing" },
    { area: "Lakeshore", name: "Shoreline Trail", description: <<~TEXT.squish,
      A pebbly trail that hugs the lake, sometimes on the shingle, sometimes up among the reeds. Shoreline Trail connects Shingle Beach and the Boathouse, and the path back into the woods meets it at the north end.
    TEXT
      places: [ [ "Shingle Beach", "Shingle Beach", "outdoor" ], [ "Boathouse", "The Boathouse", "building" ] ], was_entered_at: "Shingle Beach" }
  ].freeze

  # Streets that join (the first one's Path to the second is the direction;
  # the way back is the opposite).
  LINKS = [
    [ "Uptown Street", "Midtown Street", "S" ], [ "Midtown Street", "Downtown Street", "S" ],
    [ "High Street", "Hedgerow Lane", "E" ], [ "Hedgerow Lane", "The Towpath", "S" ],
    [ "Woodland Track", "Mossy Path", "S" ], [ "Mossy Path", "Shoreline Trail", "S" ]
  ].freeze

  # The top-level Areas open on the street of their middle neighbourhood.
  TOP_AREAS = { "City" => "Midtown Street", "Country" => "High Street", "Forest" => "Woodland Track" }.freeze

  def self.install!
    added = STREETS.filter_map { |street| add(street) }
    LINKS.each { |from, to, direction| link(from, to, direction) }
    TOP_AREAS.each { |area_name, street| open_on(Area.find_by(name: area_name), Room.find_by(name: street)) }
    added
  end

  def self.add(street)
    area = Area.find_by(name: street[:area])
    rooms = street[:places].map { |_, room_name, _| Room.find_by(name: room_name) }
    return unless area && rooms.all?

    room = Room.find_or_create_by!(name: street[:name]) do |r|
      r.area = area
      r.kind = "street"
      r.description = street[:description]
    end
    street[:places].zip(rooms).each do |(exit_name, _, kind), place|
      place.update!(kind: kind) if place.kind == "plain"
      Exit.find_or_create_by!(source_room: room, name: exit_name) { |e| e.destination_room = place; e.kind = "building" }
      Exit.find_or_create_by!(source_room: place, name: room.name) { |e| e.destination_room = room; e.kind = "building"; e.direction = "OUT" }
    end
    open_on(area, room, was: street[:was_entered_at])
    room
  end

  def self.link(from_name, to_name, direction)
    from = Room.find_by(name: from_name)
    to = Room.find_by(name: to_name)
    return unless from && to

    Exit.find_or_create_by!(source_room: from, name: to.name) { |e| e.destination_room = to; e.kind = "street"; e.direction = direction }
    Exit.find_or_create_by!(source_room: to, name: from.name) { |e| e.destination_room = from; e.kind = "street"; e.direction = Exit.opposite(direction) }
  end

  # An Area opens on the street if it has no entrance yet or still opens on
  # the sample Place the street replaced.
  def self.open_on(area, room, was: nil)
    return unless area && room
    current = area.entrance_room
    area.update!(entrance_room: room) if current.nil? || (was && current.name == was) || (area.parent.nil? && current.name.in?(old_top_entrances))
  end

  def self.old_top_entrances = [ "Central Square", "Village Green", "The Trailhead" ]
end
