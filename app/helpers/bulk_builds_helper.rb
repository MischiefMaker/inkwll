module BulkBuildsHelper
  # The choices for a Path's ends on the "Build several" screen: the new
  # Settings typed in above ("new-<key>"), then existing ones by Area.
  def bulk_build_room_options(room_rows, selected)
    new_rooms = room_rows.each_with_index.map do |row, index|
      label = row[:name].presence || "#{term(:room)} #{index + 1} (no name yet)"
      [ label, "#{BulkBuild::NEW_PREFIX}#{row[:key]}" ]
    end
    existing = Room.includes(:area).order(:name).group_by(&:area).sort_by { |area, _| area.name }
      .map { |area, rooms| [ area.name, rooms.map { |room| [ room.name, room.id.to_s ] } ] }

    safe_join([
      tag.option("Choose a #{term(:room).downcase}", value: ""),
      tag.optgroup(options_for_select(new_rooms, selected), label: "New #{term(:room, count: 2).downcase}", class: "bulk-build__new-rooms"),
      grouped_options_for_select(existing, selected)
    ])
  end
end
