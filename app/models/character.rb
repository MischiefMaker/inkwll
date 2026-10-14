# An in-character identity owned by an account. Always located in exactly one room.
class Character < ApplicationRecord
  belongs_to :account
  belongs_to :room

  normalizes :name, with: ->(n) { n.squish }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { case_sensitive: false }

  before_validation :place_in_starting_room, on: :create

  after_commit :refresh_rooms, on: [ :create, :update ], if: :saved_change_to_room_id?

  # Moves the character through an exit in its current room.
  def move_through(exit)
    raise ArgumentError, "That #{Term[:exit].downcase} is not in #{name}'s #{Term[:room].downcase}." unless exit.source_room_id == room_id
    update!(room: exit.destination_room)
  end

  private
    def place_in_starting_room
      self.room ||= Room.starting
    end

    # Tells anyone viewing the old or new room to reload the list of who is here.
    def refresh_rooms
      Room.where(id: room_id_previous_change.compact).find_each(&:broadcast_refresh)
    end
end
