# Creates a starting Area and a few placeholder Settings so a fresh game has
# somewhere to stand. Safe to run more than once. Rename or replace these from
# the admin panel's Building section.

world = Area.find_or_create_by!(name: "The World") do |area|
  area.description = "A placeholder area. Edit it from the admin panel."
end

commons = Room.find_or_create_by!(name: "The Commons") do |room|
  room.area = world
  room.description = "A placeholder starting room. Edit it from the admin panel."
  room.starting = true
end

north = Room.find_or_create_by!(name: "North Hall") do |room|
  room.area = world
  room.description = "A placeholder room to the north."
end

garden = Room.find_or_create_by!(name: "Garden") do |room|
  room.area = world
  room.description = "A placeholder room to the east."
end

[
  [ commons, north, "North" ],
  [ north, commons, "South" ],
  [ commons, garden, "East" ],
  [ garden, commons, "West" ]
].each do |source, destination, name|
  Exit.find_or_create_by!(source_room: source, name: name) { |e| e.destination_room = destination }
end
