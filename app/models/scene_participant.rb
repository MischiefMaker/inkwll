# A character taking part in a scene. Position is the order they joined in,
# which is also the turn order. The storyteller role is only for accounts
# with the Storyteller flag, or staff.
class SceneParticipant < ApplicationRecord
  belongs_to :scene
  belongs_to :character

  enum :role, { player: "player", storyteller: "storyteller" }, validate: true

  validates :character_id, uniqueness: { scope: :scene_id }
  validate :storyteller_needs_permission

  # Passages by others this character hasn't seen yet.
  def unread_count
    scene.poses.story.where("sequence > ?", last_read_sequence).where.not(character_id: character_id).count
  end

  # The unread Passages to put in an email: by other players, and not removed
  # or hidden by staff.
  def unread_passages
    scene.poses.story.where("sequence > ?", last_read_sequence)
      .where.not(character_id: character.account.characters.select(:id))
      .where(removed_at: nil, hidden_by_staff_at: nil).includes(:character)
  end

  # Emails are bundled: after one email about this scene, the next waits
  # until the player has read it.
  def emailed_since_last_read?
    notified_up_to > last_read_sequence
  end

  def mark_emailed!
    update_column(:notified_up_to, scene.last_sequence)
  end

  def mark_read!(up_to = scene.last_sequence)
    update_column(:last_read_sequence, up_to) if up_to > last_read_sequence
  end

  private
    def storyteller_needs_permission
      errors.add(:role, "storyteller needs the Storyteller flag") if storyteller? && !character.account.may_storytell?
    end
end
