# An in-character place, shown to players as a Setting. Characters move
# between rooms through exits (Paths). Every room belongs to an area.
class Room < ApplicationRecord
  include DescribedWithImage

  belongs_to :area
  has_many :exits, -> { order(:name) }, foreign_key: :source_room_id, dependent: :destroy, inverse_of: :source_room
  has_many :entrances, class_name: "Exit", foreign_key: :destination_room_id, dependent: :destroy, inverse_of: :destination_room
  has_many :characters, -> { active.order(:name) }, dependent: :restrict_with_error, inverse_of: :room
  has_many :saved_places, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 80 }

  after_save :clear_other_starting_rooms, if: -> { starting? && saved_change_to_starting? }

  # The room new characters are placed in. A game always has one: if there are
  # no rooms at all yet, a default starting room is made.
  def self.starting
    find_by(starting: true) || order(:id).first || create_default_starting_room!
  end

  def self.create_default_starting_room!
    area = Area.order(:id).first || Area.create!(name: "The World")
    create!(area: area, name: "The Commons", starting: true,
      description: "The default starting #{Term[:room].downcase}. Rename it or replace it from the admin panel.")
  end

  private
    def clear_other_starting_rooms
      Room.where.not(id: id).where(starting: true).update_all(starting: false)
    end
end
