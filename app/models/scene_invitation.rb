# An invitation for a character to read and join a private or hidden scene.
class SceneInvitation < ApplicationRecord
  belongs_to :scene
  belongs_to :character

  validates :character_id, uniqueness: { scope: :scene_id, message: "is already invited" }
end
