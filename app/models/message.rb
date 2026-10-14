# One message in a Messages conversation.
class Message < ApplicationRecord
  belongs_to :conversation, inverse_of: :messages
  belongs_to :account, optional: true

  validates :body, presence: true, length: { maximum: 10_000 }

  # The sender as the others see them (see ConversationMember#label).
  def sender_label
    conversation.member_for(account)&.label || "Someone who has left"
  end
end
