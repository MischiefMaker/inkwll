# An in-character place. Characters move between rooms through exits.
class Room < ApplicationRecord
  has_many :exits, -> { order(:name) }, foreign_key: :source_room_id, dependent: :destroy, inverse_of: :source_room
  has_many :entrances, class_name: "Exit", foreign_key: :destination_room_id, dependent: :destroy, inverse_of: :destination_room
  has_many :characters, -> { order(:name) }, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 80 }

  after_save :clear_other_starting_rooms, if: -> { starting? && saved_change_to_starting? }

  # The room new characters are placed in.
  def self.starting
    find_by(starting: true) || order(:id).first
  end

  private
    def clear_other_starting_rooms
      Room.where.not(id: id).where(starting: true).update_all(starting: false)
    end
end
