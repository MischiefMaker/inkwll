# The world timeline: staff mark a finished Chapter as a world event, with an
# optional line saying what happened. The Timeline page lists them in the
# game's own date order, with the characters who were there.
module Scene::WorldEvent
  extend ActiveSupport::Concern

  NOTE_LENGTH = 300

  included do
    belongs_to :world_event_by, class_name: "Account", optional: true
    normalizes :world_event_note, with: ->(text) { text.squish.presence }
    validates :world_event_note, length: { maximum: NOTE_LENGTH }
    scope :world_events, -> { where.not(world_event_at: nil).order(:ic_date, :finished_at) }
  end

  # Staff who build the world mark world events.
  def self.marker?(account)
    account&.can?(:build) || false
  end

  def world_event?
    world_event_at.present?
  end

  def mark_world_event!(by:, note:)
    update!(world_event_at: world_event_at || Time.current, world_event_by: by, world_event_note: note)
  end

  def unmark_world_event!
    update!(world_event_at: nil, world_event_by: nil, world_event_note: nil)
  end
end
