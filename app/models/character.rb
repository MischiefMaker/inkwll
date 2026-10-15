# An in-character identity owned by an account. Always located in exactly one room.
class Character < ApplicationRecord
  include SoulSheet
  include SoulExtras
  include Roster
  include GrimoireBook

  # Played characters that aren't retired. GM stand-ins (see Account#gm!)
  # never count as characters in lists.
  scope :active, -> { where(retired_at: nil, gm: false) }
  scope :played, -> { where(gm: false) }

  belongs_to :account
  belongs_to :room
  belongs_to :character_group, optional: true
  has_many :scene_participants, dependent: :destroy
  has_many :scenes, through: :scene_participants
  has_many :scene_invitations, dependent: :destroy
  has_many :poses, dependent: :nullify
  has_many :profile_values, dependent: :delete_all, autosave: true
  has_many :gallery_images, dependent: :destroy
  has_many :relationships, dependent: :delete_all
  has_many :relationships_with, class_name: "Relationship", foreign_key: :other_character_id, dependent: :nullify, inverse_of: :other_character
  belongs_to :reviewed_by, class_name: "Account", optional: true

  # Applications: a new character is a draft until its player submits it,
  # then staff approve it or return it with a note. Games that don't need
  # approval skip straight to approved.
  enum :status, { draft: "draft", submitted: "submitted", approved: "approved", returned: "returned" }, validate: true

  # The small picture shown beside every one of this character's Passages.
  has_one_attached :icon
  attribute :remove_icon, :boolean, default: false

  normalizes :name, with: ->(n) { n.squish }

  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { case_sensitive: false }
  validate :icon_is_a_reasonable_picture
  validates_associated :profile_values

  after_save { icon.purge_later if remove_icon && icon.attached? }

  before_validation :place_in_starting_room, on: :create
  before_validation -> { self.status = "draft" if GameSetting.current.approval_required? && !gm? }, on: :create

  after_commit :refresh_rooms, on: [ :create, :update ], if: :saved_change_to_room_id?
  after_commit -> { StaffWaiting.refresh_bells! }, if: -> { saved_change_to_status? || saved_change_to_roster_requested_at? }
  after_update_commit :announce_move, if: -> { saved_change_to_room_id? && !gm? }
  # Moving counts as being active, for the Where list's idle times.
  before_update -> { self.last_active_at = Time.current }, if: :room_id_changed?

  # Whether the character can take part in Chapters: approved, or the game
  # doesn't need approval.
  def can_play?
    !retired? && (approved? || !GameSetting.current.approval_required?)
  end

  # --- Retiring ------------------------------------------------------------------
  # Characters are never deleted. A retired character can't be played and
  # leaves the Where list and Settings, but its Passages and Manuscripts stay.

  def retired? = retired_at.present?

  # Retiring leaves any unfinished Chapters, so they don't wait on a turn
  # that can never be taken.
  def retire!
    return retire_from_roster! if roster_kept?

    transaction do
      leave_open_scenes!
      update!(retired_at: Time.current)
      account.step_away_from(self)
    end
  end

  def unretire!
    update!(retired_at: nil)
  end

  def leave_open_scenes!
    scene_participants.includes(:scene).each do |participant|
      participant.scene.leave!(self) unless participant.scene.finished?
    end
  end

  # --- Profile -----------------------------------------------------------------

  def profile_value_for(field)
    profile_values.detect { |value| value.profile_field_id == field.id }
  end

  # Saves the profile fields from the edit form: { field_id => text }.
  # Picture fields get an uploaded file; an empty one keeps the old picture.
  # Who is changing the profile, so locked fields can be refused. Left
  # empty by code that isn't a person editing (seeds, roster take-overs).
  attr_accessor :profile_editor

  def profile=(values)
    values.to_h.each do |field_id, text|
      field = ProfileField.find_by(id: field_id) or next
      next if profile_editor && field.locked_for?(self, profile_editor)
      if field.image?
        next unless text.respond_to?(:original_filename)
        profile_value_built_for(field).picture = text
      else
        profile_value_built_for(field).value = text.to_s.strip.presence
      end
    end
  end

  # Picture fields ticked "Remove this picture" on the edit form.
  def remove_profile_pictures=(field_ids)
    ProfileField.where(id: Array(field_ids), field_type: "image").find_each do |field|
      next if profile_editor && field.locked_for?(self, profile_editor)
      value = profile_value_for(field)
      value.picture = nil if value && !value.attachment_changes["image"]
    end
  end

  def profile_value_built_for(field)
    profile_value_for(field) || profile_values.build(profile_field: field)
  end

  def birthday
    field = ProfileField.find_by(field_type: "birthday") or return
    profile_value_for(field)&.as_date
  end

  def age
    IcClock.age(birthday)
  end

  # Whether the player may still pick this character's group themselves.
  def group_choosable?
    !approved? || !GameSetting.current.approval_required?
  end

  # --- Applications ------------------------------------------------------------

  # What's still needed before the character can be submitted.
  def missing_for_submission
    settings = GameSetting.current
    missing = ProfileField.where(required: true).ordered.reject { |field| profile_value_for(field)&.value.present? }.map(&:name)
    missing << "an icon" if settings.require_icon? && !icon.attached?
    missing
  end

  def submit!
    return false unless (draft? || returned?) && missing_for_submission.empty?
    update!(status: "submitted", submitted_at: Time.current)
  end

  def approve!(by:)
    update!(status: "approved", reviewed_at: Time.current, reviewed_by: by, review_note: nil)
    start_inklings_from_profile!
    lock_sheet!
    NotificationMailer.application_decision(self).deliver_later if account.wants_email?
  end

  # Answers to profile fields set to start an Inkling (such as Goals or
  # Secrets) become Inklings of that type once the character is approved,
  # started by the player. A character that already has one of that title
  # isn't given a second.
  def start_inklings_from_profile!
    return unless Inkling.enabled?
    ProfileField.where.not(inkling_kind: [ nil, "" ]).ordered.each do |field|
      text = profile_value_for(field)&.value.presence or next
      next unless ProfileField.inkling_kinds.key?(field.inkling_kind)
      next if Inkling.exists?(character: self, kind: field.inkling_kind, title: field.name)
      Inkling.start!(character: self, by: account, kind: field.inkling_kind, title: field.name, body: text)
    end
  end

  def return!(by:, note:)
    update!(status: "returned", reviewed_at: Time.current, reviewed_by: by, review_note: note.to_s.strip.presence)
    NotificationMailer.application_decision(self).deliver_later if account.wants_email?
  end

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

    # Makes moving feel physical: Chapters in the Setting the character left
    # and the one they arrived in get a line about it. Idle Chapters don't.
    def announce_move
      from = Room.find(room_id_previous_change.first)
      Scene.active.where(room: from).find_each { |scene| scene.add_system_line!("#{name} leaves for #{room.name}.") }
      Scene.active.where(room: room).find_each { |scene| scene.add_system_line!("#{name} arrives from #{from.name}.") }
    end

    # Tells anyone viewing the old or new room to reload the list of who is here.
    def refresh_rooms
      Room.where(id: room_id_previous_change.compact).find_each(&:broadcast_refresh)
    end
end
