# An in-character identity owned by an account. Always located in exactly one room.
class Character < ApplicationRecord
  belongs_to :account
  belongs_to :room
  has_many :scene_participants, dependent: :destroy
  has_many :scenes, through: :scene_participants
  has_many :scene_invitations, dependent: :destroy
  has_many :poses, dependent: :nullify

  # The small picture shown beside every one of this character's Passages.
  has_one_attached :icon
  attribute :remove_icon, :boolean, default: false

  normalizes :name, with: ->(n) { n.squish }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { case_sensitive: false }
  validate :icon_is_a_reasonable_picture

  after_save { icon.purge_later if remove_icon && icon.attached? }

  before_validation :place_in_starting_room, on: :create

  after_commit :refresh_rooms, on: [ :create, :update ], if: :saved_change_to_room_id?

  # Moves the character through an exit in its current room.
  def move_through(exit)
    raise ArgumentError, "That #{Term[:exit].downcase} is not in #{name}'s #{Term[:room].downcase}." unless exit.source_room_id == room_id
    update!(room: exit.destination_room)
  end

  private
    # Same rules as images on Areas and Settings (see DescribedWithImage).
    def icon_is_a_reasonable_picture
      return unless icon.attached? && attachment_changes["icon"]
      errors.add(:icon, "must be a picture (PNG, JPEG, GIF or WebP)") unless icon.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
      errors.add(:icon, "must be smaller than 5 MB") if icon.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
    end

    def place_in_starting_room
      self.room ||= Room.starting
    end

    # Tells anyone viewing the old or new room to reload the list of who is here.
    def refresh_rooms
      Room.where(id: room_id_previous_change.compact).find_each(&:broadcast_refresh)
    end
end
