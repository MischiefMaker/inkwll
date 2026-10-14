# An in-character place, shown to players as a Setting. Characters move
# between rooms through exits (Paths). Every room belongs to an area.
class Room < ApplicationRecord
  include DescribedWithImage

  belongs_to :area
  has_many :exits, -> { order(:name) }, foreign_key: :source_room_id, dependent: :destroy, inverse_of: :source_room
  has_many :entrances, class_name: "Exit", foreign_key: :destination_room_id, dependent: :destroy, inverse_of: :destination_room
  has_many :characters, -> { active.order(:name) }, dependent: :restrict_with_error, inverse_of: :room
  has_many :saved_places, dependent: :delete_all

  # Special Setting types. Each one names its numbered list of Paths and the
  # rooms the "Add numbered rooms" tool makes ("Apartment 100"). Ordinary
  # Settings can still have numbered Paths; their list is called "Doors".
  KINDS = {
    "plain" => { label: "Ordinary", list: "Doors", unit: "Room" },
    "apartments" => { label: "Apartment building", list: "Apartments", unit: "Apartment" },
    "hotel" => { label: "Hotel or inn", list: "Rooms", unit: "Room" },
    "dorms" => { label: "Dormitory", list: "Dorm rooms", unit: "Dorm room" },
    "offices" => { label: "Office block", list: "Offices", unit: "Office" },
    "street" => { label: "Street of houses", list: "Houses", unit: "House" }
  }.freeze

  validates :name, presence: true, length: { maximum: 80 }
  validates :kind, inclusion: { in: KINDS.keys }

  # Settings worth listing on their own in Areas and Shortcuts: everything
  # except the rooms behind a numbered door, which are reached from their
  # building so a block of 50 apartments doesn't flood the lists.
  scope :listed, -> { where.not(id: Exit.numbered.select(:destination_room_id)) }

  after_save :clear_other_starting_rooms, if: -> { starting? && saved_change_to_starting? }

  # The "Default Setting for its Area" tick box on the Setting form: Enter on
  # the front page moves a character here. Left alone when the form doesn't
  # send it.
  attribute :area_default, :boolean
  after_save :save_area_default, unless: -> { area_default.nil? }

  def area_default?
    area_default.nil? ? area&.entrance_room_id == id : area_default
  end

  # The room new characters are placed in. A game always has one: if there are
  # no rooms at all yet, a default starting room is made.
  def self.starting
    find_by(starting: true) || order(:id).first || create_default_starting_room!
  end

  def save_area_default
    if area_default
      area.update_column(:entrance_room_id, id)
      Area.where(entrance_room_id: id).where.not(id: area_id).update_all(entrance_room_id: nil) if saved_change_to_area_id?
    elsif area.entrance_room_id == id
      area.update_column(:entrance_room_id, nil)
    end
  end
  private :save_area_default

  def kind_details
    KINDS.fetch(kind, KINDS["plain"])
  end

  # What the numbered list is called here: "Apartments", "Rooms", "Doors".
  def numbered_list_title
    kind_details[:list]
  end

  # What one numbered room is called: "Apartment", "Room".
  def numbered_unit
    kind_details[:unit]
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
