# A group of rooms ("Settings"), shown to players as an Area. Areas can sit
# inside other areas, as deep as a game likes: Hogwarts > Castle > First Floor.
# Characters are never "in" an area, only in one of its rooms.
class Area < ApplicationRecord
  include DescribedWithImage

  belongs_to :parent, class_name: "Area", optional: true
  # The Setting players arrive at when they open this area.
  belongs_to :entrance_room, class_name: "Room", optional: true
  has_many :children, -> { order(:position, :name) }, class_name: "Area", foreign_key: :parent_id,
    dependent: :restrict_with_error, inverse_of: :parent
  has_many :rooms, -> { order(:name) }, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 80 }
  validate :parent_is_not_inside_itself
  validate :entrance_is_inside_this_area

  scope :top_level, -> { where(parent_id: nil).order(:position, :name) }

  # Why this Area can't be deleted yet; empty when it can. Its Places and
  # inner Areas have to be deleted or moved first.
  def deletion_blockers
    blockers = []
    blockers << "It has #{children.count} #{Term[:area, count: 2].downcase} inside it. Delete or move them first." if children.exists?
    blockers << "It has #{rooms.count} #{Term[:room, count: 2].downcase} in it. Delete or move them first." if rooms.exists?
    blockers
  end

  def deletable? = deletion_blockers.empty?

  # Where Enter on the front page takes a character: the area's chosen
  # default Setting, or failing that the first Setting made in it, or the
  # entrance of the first area inside it.
  def entrance
    return entrance_room if entrance_room
    first_made = rooms.listed.reorder(:created_at, :id).first || rooms.reorder(:created_at, :id).first
    return first_made if first_made
    children.each do |child|
      found = child.entrance
      return found if found
    end
    nil
  end

  # Every Setting in this area and the areas inside it, for shortcut lists.
  def all_rooms
    Room.where(area_id: [ id, *descendant_ids ]).order(:name)
  end

  # The newest Passage in an open Chapter anywhere inside this area, for the
  # front page. Private and hidden Chapters never show here.
  # With own_rooms_only, only Settings directly in this area count.
  def latest_public_pose(own_rooms_only: false)
    rooms = own_rooms_only ? self.rooms : all_rooms.unscope(:order)
    Pose.story.where(removed_at: nil).joins(:scene).merge(Scene.visibility_joinable)
      .where(scenes: { room_id: rooms.select(:id) })
      .includes(:character, :scene).order(created_at: :desc).first
  end

  # The areas above this one, outermost first: [Hogwarts, Castle] for First Floor.
  def ancestors
    chain = []
    area = parent
    while area
      chain.unshift(area)
      area = area.parent
    end
    chain
  end

  # Every area inside this one, at any depth.
  # Remembered for the life of this record, because the front page asks
  # several times per Area.
  def descendant_ids
    @descendant_ids ||= begin
      ids = children.pluck(:id)
      ids + Area.where(id: ids).flat_map(&:descendant_ids)
    end
  end

  def reload(*)
    @descendant_ids = nil
    super
  end

  # All areas in nesting order, each with its depth, for dropdowns.
  def self.nested_options(except: nil)
    excluded = except ? [ except.id, *except.descendant_ids ] : []
    walk = ->(areas, depth) do
      areas.reject { |a| excluded.include?(a.id) }.flat_map do |area|
        [ [ "#{"— " * depth}#{area.name}", area.id ] ] + walk.(area.children.to_a, depth + 1)
      end
    end
    walk.(top_level.to_a, 0)
  end

  private
    def entrance_is_inside_this_area
      return unless entrance_room
      unless entrance_room.area_id == id || (persisted? && descendant_ids.include?(entrance_room.area_id))
        errors.add(:entrance_room, "must be a #{Term[:room].downcase} inside this #{Term[:area].downcase}")
      end
    end

    def parent_is_not_inside_itself
      return unless parent_id && persisted?
      if parent_id == id || descendant_ids.include?(parent_id)
        errors.add(:parent, "can't be this #{Term[:area].downcase} or one inside it")
      end
    end
end
