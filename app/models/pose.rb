# One post in a scene. Kinds:
#
# - passage: a character's Passage, the usual kind.
# - npc: a Passage written by a character's player for a non-player
#   character, shown under npc_name. It takes the poster's turn.
# - narration: scene-setting text from the Storyteller (or anyone, in a
#   Chapter without one). It doesn't take a turn.
# - ooc: an out-of-character remark (brb, timing). It doesn't take a turn,
#   doesn't count as unread or in emails, and is left out of the Manuscript.
# - system: lines from the game, such as "Wren joins the Chapter.", with no
#   character.
#
# Players can edit or remove their own poses until the scene finishes. The
# first version is kept in original_body so staff can see what was really
# posted, and removed poses keep their text but show as removed.
class Pose < ApplicationRecord
  belongs_to :scene, inverse_of: :poses
  belongs_to :character, optional: true

  enum :kind, { passage: "passage", npc: "npc", narration: "narration", ooc: "ooc", system: "system" }, validate: true

  # Kinds that are part of the story: shown in Manuscripts, counted as unread
  # and sent in emails.
  STORY_KINDS = %w[ passage npc narration ].freeze
  # Kinds that take the poster's turn.
  TURN_KINDS = %w[ passage npc ].freeze

  scope :story, -> { where(kind: STORY_KINDS) }
  scope :turn_taking, -> { where(kind: TURN_KINDS) }

  normalizes :npc_name, with: ->(name) { name.strip.presence }

  validates :body, presence: true, length: { maximum: 20_000 }
  validates :character, presence: true, unless: :system?
  validates :npc_name, presence: true, length: { maximum: 60 }, if: :npc?

  after_create_commit { scene.broadcast_change }
  after_create_commit -> { Notifier.passage_posted(self) }, if: :story?
  after_update_commit { scene.broadcast_change }

  def edit!(new_body)
    self.original_body ||= body
    update!(body: new_body, edited_at: Time.current)
  end

  def remove!
    update!(removed_at: Time.current)
  end

  # Staff can hide a Passage after a report. The text is kept for staff.
  def hide_by_staff!
    update!(hidden_by_staff_at: Time.current)
  end

  def hidden_by_staff?
    hidden_by_staff_at.present?
  end

  def edited?
    edited_at.present?
  end

  def removed?
    removed_at.present?
  end

  def story?
    STORY_KINDS.include?(kind)
  end

  # The name shown at the top: the NPC's name for NPC Passages.
  def display_name
    npc? ? npc_name : character&.name
  end
end
