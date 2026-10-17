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
      if (account = Account.find_by(username: name.downcase, system: false))
        raise UnknownName, "#{account.display_name} has left the game, so they can't get Messages." if account.archived?
        [ account, nil ]
      elsif (character = Character.where("lower(name) = ?", name.downcase).first)
        # Nobody reads Messages sent to the roster or to an archived player.
        raise UnknownName, "Nobody is playing #{character.name} right now." if character.account.system? || character.account.archived?
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

  # A page: a quick message to one player that opens as a live chat tab for
  # both of them. Reuses their last page conversation if there is one.
  PAGE_SUBJECT = "Pages".freeze

  def self.page!(from:, to:, body:)
    account, character = to
    existing = joins(:members).where(subject: PAGE_SUBJECT, conversation_members: { account_id: from.id, left_at: nil })
      .where(id: ConversationMember.active.where(account_id: account.id).select(:conversation_id))
      .where(id: ConversationMember.group(:conversation_id).having("count(*) = 2").select(:conversation_id))
      .by_activity.first
    conversation = existing || transaction do
      create!(subject: PAGE_SUBJECT).tap do |c|
        c.members.create!(account: from)
        c.members.create!(account: account, via_character: character)
      end
    end
    conversation.post!(from, body, live: true)
    conversation
  end

  # Messages in the chat sidebar: opens the tab for everyone still in it (live)
  # or just for one person.
  def open_live!(only: nil)
    opening = members.active.where(live_open: false)
    opening = opening.where(account: only) if only
    opening.includes(:account).each do |member|
      member.update!(live_open: true)
      member.account.broadcast_private_chats
    end
  end

  def post!(account, body, live: false)
    member = member_for(account) or raise ArgumentError, "You're not in this conversation."
    raise ArgumentError, "You've left this conversation." unless member.active?

    message = messages.create!(account: account, body: body)
    update!(last_message_at: message.created_at)
    member.update!(last_read_at: message.created_at)
    broadcast_refresh_later
    message.broadcast_append_later_to [ self, :live ], target: "private_chat_messages_#{id}", partial: "private_chats/message", locals: { message: message }
    open_live! if live
    active_members.each { |m| m.account.broadcast_message_count }
    Notifier.message_posted(message)
    message
  end
end
