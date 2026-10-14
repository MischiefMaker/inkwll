# A Messages conversation: out-of-character, between players, one-to-one or
# a small group. Replies stay in the same conversation.
#
# Someone can be added as "the player of" a character. Unless the game shows
# who plays which character, they're then shown only that way to everyone
# else in the conversation, so it never reveals who they are.
class Conversation < ApplicationRecord
  MAX_RECIPIENTS = 8

  has_many :members, class_name: "ConversationMember", dependent: :destroy
  has_many :messages, -> { order(:created_at, :id) }, dependent: :destroy, inverse_of: :conversation

  validates :subject, presence: true, length: { maximum: 120 }

  scope :by_activity, -> { order(Arel.sql("COALESCE(conversations.last_message_at, conversations.created_at) DESC")) }

  class UnknownName < StandardError; end

  # Turns "Robin, Wren" into who to add: a player by player name, or the
  # player of a character by character name. Returns [account, character].
  def self.resolve(names, from:)
    names.to_s.split(",").map(&:squish).reject(&:blank?).uniq.map do |name|
      if (account = Account.find_by(username: name.downcase))
        [ account, nil ]
      elsif (character = Character.where("lower(name) = ?", name.downcase).first)
        [ character.account, (character unless GameSetting.current.players_public?) ]
      else
        raise UnknownName, "There's no player or character called \"#{name}\"."
      end
    end.reject { |account, _| account == from }.uniq(&:first)
  end

  def self.start!(from:, recipients:, subject:, body:)
    raise UnknownName, "Add at least one other player." if recipients.empty?
    raise UnknownName, "A conversation can have up to #{MAX_RECIPIENTS} other people." if recipients.size > MAX_RECIPIENTS

    transaction do
      conversation = create!(subject: subject)
      conversation.members.create!(account: from)
      recipients.each { |account, character| conversation.members.create!(account: account, via_character: character) }
      conversation.post!(from, body)
      conversation
    end
  end

  def member_for(account)
    members.detect { |member| member.account_id == account&.id }
  end

  def active_members
    members.select(&:active?)
  end

  def post!(account, body)
    member = member_for(account) or raise ArgumentError, "You're not in this conversation."
    raise ArgumentError, "You've left this conversation." unless member.active?

    message = messages.create!(account: account, body: body)
    update!(last_message_at: message.created_at)
    member.update!(last_read_at: message.created_at)
    broadcast_refresh_later
    active_members.each { |m| m.account.broadcast_message_count }
    Notifier.message_posted(message)
    message
  end
end
