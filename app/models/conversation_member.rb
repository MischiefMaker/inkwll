# Someone in a Messages conversation, and how far they've read.
class ConversationMember < ApplicationRecord
  belongs_to :conversation
  belongs_to :account
  belongs_to :via_character, class_name: "Character", optional: true

  validates :account_id, uniqueness: { scope: :conversation_id }

  scope :active, -> { where(left_at: nil) }

  def active?
    left_at.nil?
  end

  # How this person is shown to the others: "Robin", or "The player of Wren".
  def label
    via_character ? "The player of #{via_character.name}" : account.display_name
  end

  def unread?
    conversation.last_message_at.present? && (last_read_at.nil? || conversation.last_message_at > last_read_at)
  end

  def unread_messages
    scope = conversation.messages.where.not(account_id: account_id)
    last_read_at ? scope.where("messages.created_at > ?", last_read_at) : scope
  end

  # One email per conversation until it's read again.
  def emailed_since_last_read?
    emailed_at.present? && (last_read_at.nil? || emailed_at > last_read_at)
  end

  def mark_read!
    update_column(:last_read_at, Time.current)
    account.broadcast_message_count
  end
end
