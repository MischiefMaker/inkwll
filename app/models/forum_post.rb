# One post in a forum thread, shown under the player's name (like the OOC
# Chat), or on an in-character board under the character it was posted as.
# Written in Markdown.
class ForumPost < ApplicationRecord
  belongs_to :topic, class_name: "ForumTopic", inverse_of: :posts, counter_cache: :posts_count, touch: false
  belongs_to :account, optional: true
  belongs_to :character, optional: true

  validate :posted_as_own_character, if: -> { character_id_changed? && character }

  validates :body, presence: true, length: { maximum: 20_000 }

  after_create_commit { topic.update_column(:last_posted_at, created_at) }

  def opening? = topic.posts.first == self

  private
    def posted_as_own_character
      errors.add(:character, "must be one of your characters") unless character.account_id == account_id && character.can_play?
    end

  public

  def editable_by?(account)
    account.present? && (account == self.account || ForumTopic.moderator?(account))
  end
end
