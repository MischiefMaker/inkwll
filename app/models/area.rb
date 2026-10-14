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

  # Where players arrive when they open this area: its chosen entrance, or
  # failing that its first Setting, or the entrance of the first area inside it.
  def entrance
    return entrance_room || rooms.first if entrance_room || rooms.any?
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
  def descendant_ids
    ids = children.pluck(:id)
    ids + Area.where(id: ids).flat_map(&:descendant_ids)
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
