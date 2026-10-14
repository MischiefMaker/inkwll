# A thread on a forum board. Its first post is the opening message; the rest
# are replies. Moderators can pin a thread to the top of its board or lock it
# so nobody can reply.
class ForumTopic < ApplicationRecord
  PER_PAGE = 30

  belongs_to :board, class_name: "ForumBoard", inverse_of: :topics
  belongs_to :account, optional: true
  has_many :posts, -> { order(:created_at, :id) }, class_name: "ForumPost", foreign_key: :topic_id,
    inverse_of: :topic, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  normalizes :title, with: ->(title) { title.squish }

  before_validation(on: :create) { self.last_posted_at ||= Time.current }

  def pinned? = pinned_at.present?
  def locked? = locked_at.present?

  # Moderators (Scribes and Wellkeepers) pin, lock and delete threads and posts.
  def self.moderator?(account)
    account&.can?(:handle_reports) || false
  end

  def may_reply?(account)
    (!locked? || self.class.moderator?(account)) && board.may_reply?(account)
  end

  # Starts a thread with its opening post, in one go.
  def self.start!(board:, account:, title:, body:)
    transaction do
      topic = board.topics.create!(account: account, title: title)
      topic.posts.create!(account: account, body: body)
      topic
    end
  end
end
