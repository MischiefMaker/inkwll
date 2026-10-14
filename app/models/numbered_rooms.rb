# The builder's "Add numbered rooms" tool for apartment-style Settings. Each
# line like "100 Jaxon Marley" (or "100 - Jaxon Marley") makes a new room
# called "Apartment 100" in the same Area, a numbered Path to it labelled
# "Jaxon Marley", and a Path back out. A line with just a number labels the
# Path "Apartment 100". Either every line saves or none does.
class NumberedRooms
  include ActiveModel::Model

  MAX_LINES = 100
  LINE = /\A(?<number>[A-Za-z0-9.\-]+)\s*(?:[-–—:]\s*)?(?<label>.*)\z/

  attr_reader :room, :lines, :return_name, :rooms

  def initialize(room:, lines: "", return_name: nil)
    @room = room
    @lines = lines.to_s
    @return_name = return_name.to_s.squish.presence || "Out"
    @rooms = []
    super()
  end

  def save
    errors.clear
    entries = parsed
    unreadable = entries.select { |number, _| number.nil? }
    unreadable.first(3).each { |_, line| errors.add(:base, "\"#{line}\" doesn't start with a door number.") }
    return false if unreadable.any?
    errors.add(:base, "Add at least one line, like \"100 Jaxon Marley\".") if entries.empty?
    errors.add(:base, "Add up to #{MAX_LINES} at a time.") if entries.size > MAX_LINES
    return false if errors.any?

    ActiveRecord::Base.transaction do
      entries.each { |number, label| build(number, label) }
      raise ActiveRecord::Rollback if errors.any?
    end
    @rooms = [] if errors.any?
    errors.none?
  end

  private
    def parsed
      lines.lines.map(&:squish).reject(&:blank?).map do |line|
        match = LINE.match(line)
        match ? [ match[:number], match[:label].presence ] : [ nil, line ]
      end
    end

    def build(number, label)
      name = "#{room.numbered_unit} #{number}"
      sub_room = Room.new(area: room.area, name: name, kind: "plain")
      way_in = Exit.new(source_room: room, destination_room: sub_room, number: number, name: label || name)
      way_out = Exit.new(source_room: sub_room, destination_room: room, name: return_name, direction: "OUT")
      [ sub_room, way_in, way_out ].each do |record|
        next if record.save
        record.errors.full_messages.each { |message| errors.add(:base, "#{number}: #{message}") }
        return
      end
      @rooms << sub_room
    end
end
