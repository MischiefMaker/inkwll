# An Inkling linked to a Chapter, because the Chapter started it or carried
# it on. Only the Inkling's player and staff see the link from the Inkling's
# side; in the Chapter, only the player of the linked character sees it.
class InklingSceneLink < ApplicationRecord
  belongs_to :inkling
  belongs_to :scene
  belongs_to :linked_by, class_name: "Account"
  validates :scene_id, uniqueness: { scope: :inkling_id }
end
