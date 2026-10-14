# A label staff define for Chapters, such as a content warning. Players pick
# labels for their Chapters, and they show in the Setting's Chapter list.
class SceneLabel < ApplicationRecord
  normalizes :name, with: ->(n) { n.squish }
  validates :name, presence: true, length: { maximum: 40 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 200 }

  scope :ordered, -> { order(:position, :name) }
  after_destroy_commit { Scene.where("? = ANY(label_ids)", id).update_all([ "label_ids = array_remove(label_ids, ?)", id ]) }
end
