# An in-character place, shown to players as a Setting. Characters move
# between rooms through exits (Paths). Every room belongs to an area.
class Room < ApplicationRecord
  include DescribedWithImage

  belongs_to :area
  has_many :exits, -> { order(:name) }, foreign_key: :source_room_id, dependent: :destroy, inverse_of: :source_room
  has_many :entrances, class_name: "Exit", foreign_key: :destination_room_id, dependent: :destroy, inverse_of: :destination_room
  has_many :characters, -> { active.order(:name) }, dependent: :restrict_with_error, inverse_of: :room
  has_many :saved_places, dependent: :delete_all

  # Special Place types. Each one names its numbered list of Paths and the
  # rooms the "Add numbered rooms" tool makes ("Unit 100"). Ordinary
  # Places can still have numbered Paths; their list is called "Doors".
  KINDS = {
    "plain" => { label: "Nothing special", list: "Doors", unit: "Room" },
    "apartments" => { label: "Building (with separate units)", list: "Units", unit: "Unit" },
    "building" => { label: "Building (no units)", list: "Doors", unit: "Room" },
    "street" => { label: "Street", list: "Places", unit: "Place" },
    "outdoor" => { label: "Outdoor area (park, square...)", list: "Places", unit: "Place" }
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

  # Why this Setting can't be deleted yet, as plain sentences; empty when it
  # can. Chapters (open or finished) and characters are never thrown away
  # with it, so the Archives and character records stay safe.
  def deletion_blockers
    blockers = []
    blockers << "New characters start here. Pick another starting #{Term[:room].downcase} first." if starting?
    blockers << "It has #{Character.where(room_id: id).count} character(s) in it. Move them out first." if Character.where(room_id: id).exists?
    blockers << "It has #{Scene.where(room_id: id).count} #{Term[:scene, count: 2].downcase} (open or finished), which stay in the Archives." if Scene.where(room_id: id).exists?
    blockers
  end

  def deletable? = deletion_blockers.empty?

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

  # The out-of-character Setting new characters start in, before they step
  # into the story (owner). Made by the seeds for a new game, and once for
  # games that already existed. One-way Paths lead to the entrance of each
  # top-level Area, named after the Setting they lead to.
  PROLOGUE = "The Prologue"

  def self.create_prologue!
    return find_by(name: PROLOGUE) if exists?(name: PROLOGUE)
    transaction do
      area = Area.find_or_create_by!(name: "Out of Character") do |a|
        a.position = Area.top_level.maximum(:position).to_i + 1
        a.summary = "Outside the story, where new characters wait to step onto the page."
        a.description = "A quiet corner outside the story. New characters wait here before stepping onto the page."
      end
      entrances = Area.top_level.where.not(id: area.id).filter_map(&:entrance).uniq
      prologue = create!(area: area, name: PROLOGUE, starting: true, description: <<~TEXT.strip)
        Every story starts somewhere, and yours starts here: a hushed reading room between the covers, all lamplight and turned-down pages, where new characters wait before stepping into the tale.

        Nothing here is in character. Look around, read the Getting started guide, say hello in the OOC Chat, and when you're ready, take one of the Paths below into the story.
      TEXT
      area.update!(entrance_room: prologue)
      entrances.each { |room| prologue.exits.create!(destination_room: room, name: room.name.first(40)) }
      prologue
    end
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
