# Creates a few placeholder rooms so a fresh game has somewhere to stand.
# Safe to run more than once. Rename or replace these with the Build tools.

commons = Room.find_or_create_by!(name: "The Commons") do |room|
  room.description = "A placeholder starting room. Edit it from the Build menu."
  room.starting = true
end

north = Room.find_or_create_by!(name: "North Hall") do |room|
  room.description = "A placeholder room to the north."
end

garden = Room.find_or_create_by!(name: "Garden") do |room|
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
