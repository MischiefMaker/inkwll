# A player's report about a Chapter, or one Passage in it. A report lets
# staff who handle reports read that one Chapter, even a private or hidden
# one, and nothing else.
class Report < ApplicationRecord
  include AffectsStaffQueue
  belongs_to :scene
  belongs_to :pose, optional: true
  belongs_to :account
  belongs_to :resolved_by, class_name: "Account", optional: true
  has_many :warnings, class_name: "AccountWarning", dependent: :nullify

  validates :reason, presence: true, length: { maximum: 5_000 }
  validate :pose_is_in_the_scene

  scope :unresolved, -> { where(resolved_at: nil) }

  def resolved?
    resolved_at.present?
  end

  def resolve!(by:, note: nil)
    update!(resolved_at: Time.current, resolved_by: by, resolution: note.presence)
  end

  private
    def pose_is_in_the_scene
      errors.add(:pose, "isn't in this #{Term[:scene]}") if pose && pose.scene_id != scene_id
    end
end
