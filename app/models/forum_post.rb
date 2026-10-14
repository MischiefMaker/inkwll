# One post in a forum thread, shown under the player's name (like the OOC
# Chat), not a character's. Written in Markdown.
class ForumPost < ApplicationRecord
  belongs_to :topic, class_name: "ForumTopic", inverse_of: :posts, counter_cache: :posts_count, touch: false
  belongs_to :account, optional: true

  validates :body, presence: true, length: { maximum: 20_000 }

  after_create_commit { topic.update_column(:last_posted_at, created_at) }

  def opening? = topic.posts.first == self

  def editable_by?(account)
    account.present? && (account == self.account || ForumTopic.moderator?(account))
  end
end
