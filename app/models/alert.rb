# One entry under the alerts bell: a new Passage in your Chapter, your turn,
# an @mention, or a Chapter you were in being finished.
#
# New Passages (and turns) in the same Chapter add to one unread alert
# rather than making a new one each time, so the bell doesn't fill up.
class Alert < ApplicationRecord
  KINDS = %w[ passage turn mention finished ].freeze
  COLLAPSING_KINDS = %w[ passage turn ].freeze
  KEEP_READ_FOR = 30.days
  SHOWN = 50

  belongs_to :account
  belongs_to :character, optional: true
  belongs_to :scene, optional: true
  belongs_to :pose, optional: true

  validates :kind, inclusion: { in: KINDS }

  scope :unread, -> { where(read_at: nil) }
  scope :newest_first, -> { order(updated_at: :desc) }

  def self.notify!(account, kind, scene:, character: nil, pose: nil)
    existing = unread.find_by(account: account, kind: kind, scene: scene) if kind.in?(COLLAPSING_KINDS)
    if existing
      existing.update!(count: existing.count + 1, pose: pose || existing.pose, character: character || existing.character, updated_at: Time.current)
    else
      create!(account: account, kind: kind, scene: scene, character: character, pose: pose)
    end
    account.broadcast_alert_count
  end

  # Opening a Chapter reads its alerts.
  def self.read_for!(account, scene)
    changed = unread.where(account: account, scene: scene).update_all(read_at: Time.current)
    account.broadcast_alert_count if changed.positive?
  end

  def self.read_all!(account)
    unread.where(account: account).update_all(read_at: Time.current)
    account.broadcast_alert_count
  end

  def self.clean_up!(now = Time.current)
    where(read_at: ...(now - KEEP_READ_FOR)).delete_all
  end

  def unread? = read_at.nil?
end
