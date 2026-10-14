# Builds several rooms (Settings) and the exits (Paths) between them in one
# go, for the admin "Build several" screen. Either everything saves or
# nothing does.
#
# Rooms come in as rows keyed by a made-up key ("1", "2", ...). Exits name
# their ends either by an existing room's id or by "new-<key>" for a room
# being made in the same batch. Rows left completely blank are ignored.
class BulkBuild
  include ActiveModel::Model

  NEW_PREFIX = "new-".freeze

  attr_reader :area_id, :room_rows, :path_rows, :rooms, :exits

  def initialize(params = {})
    params = params.to_h.with_indifferent_access
    @area_id = params[:area_id].presence
    @room_rows = rows(params[:rooms], %i[ name description ])
    @path_rows = rows(params[:paths], %i[ from name to return_name ])
    @rooms = []
    @exits = []
    super()
  end

  # Two empty Settings and one empty Path, for a fresh form.
  def self.blank(area_id: nil)
    new(area_id: area_id, rooms: { "1" => {}, "2" => {} }, paths: { "1" => {} })
  end

  def area
    Area.find_by(id: area_id)
  end

  def save
    errors.clear
    errors.add(:base, "Pick a #{Term[:area].downcase}.") unless area
    errors.add(:base, "Add at least one #{Term[:room].downcase}.") if filled(room_rows).empty?
    return false if errors.any?

    ActiveRecord::Base.transaction do
      new_rooms = build_rooms
      build_exits(new_rooms)
      raise ActiveRecord::Rollback if errors.any?
    end
    errors.none?
  end

  private
    def rows(hash, fields)
      (hash || {}).to_h.map do |key, row|
        row = row.to_h.with_indifferent_access
        { key: key.to_s }.merge(fields.index_with { |field| row[field].to_s.strip })
      end
    end

    def filled(rows)
      rows.reject { |row| row.except(:key).values.all?(&:blank?) }
    end

    def build_rooms
      filled(room_rows).each_with_index.to_h do |row, index|
        room = Room.new(area: area, name: row[:name], description: row[:description])
        if room.save
          @rooms << room
        else
          room.errors.full_messages.each { |message| errors.add(:base, "#{Term[:room]} #{index + 1}: #{message}") }
        end
        [ row[:key], room ]
      end
    end

    def build_exits(new_rooms)
      filled(path_rows).each_with_index do |row, index|
        label = "#{Term[:exit]} #{index + 1}"
        from = find_room(row[:from], new_rooms)
        to = find_room(row[:to], new_rooms)
        if from == :failed || to == :failed
          next
        elsif from.nil? || to.nil?
          errors.add(:base, "#{label}: pick the #{Term[:room].downcase} it goes from and the one it leads to.")
        elsif from == to
          errors.add(:base, "#{label}: a #{Term[:exit].downcase} has to lead somewhere else.")
        else
          save_exit(label, from, to, row[:name])
          save_exit("#{label} (return)", to, from, row[:return_name]) if row[:return_name].present?
        end
      end
    end

    # A room being made in this batch, or one that already exists. A new room
    # that couldn't be saved gives :failed, since its own error already says why.
    def find_room(value, new_rooms)
      if value.start_with?(NEW_PREFIX)
        room = new_rooms[value.delete_prefix(NEW_PREFIX)]
        room&.new_record? ? :failed : room
      elsif value.present?
        Room.find_by(id: value)
      end
    end

    def save_exit(label, from, to, name)
      room_exit = Exit.new(source_room: from, destination_room: to, name: name)
      if room_exit.save
        @exits << room_exit
      else
        room_exit.errors.full_messages.each { |message| errors.add(:base, "#{label}: #{message}") }
      end
    end
end
