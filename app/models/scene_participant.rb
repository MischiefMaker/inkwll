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
    scene.poses.where(kind: "passage").where("sequence > ?", last_read_sequence).where.not(character_id: character_id).count
  end

  def mark_read!(up_to = scene.last_sequence)
    update_column(:last_read_sequence, up_to) if up_to > last_read_sequence
  end

  private
    def storyteller_needs_permission
      errors.add(:role, "storyteller needs the Storyteller flag") if storyteller? && !character.account.may_storytell?
    end
end
