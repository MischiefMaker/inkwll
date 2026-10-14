# One post in a scene, shown to players as a Passage. System lines (such as
# "Wren joins the Chapter.") are poses with no character.
#
# Players can edit or remove their own poses until the scene finishes. The
# first version is kept in original_body so staff can see what was really
# posted, and removed poses keep their text but show as removed.
class Pose < ApplicationRecord
  belongs_to :scene, inverse_of: :poses
  belongs_to :character, optional: true

  enum :kind, { passage: "passage", system: "system" }, validate: true

  validates :body, presence: true, length: { maximum: 20_000 }
  validates :character, presence: true, if: :passage?

  after_create_commit { scene.broadcast_change }
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
end
