# A group a game sorts characters into, such as a house or faction. Each
# group has a colour that colours its characters' names.
#
# Each group has its own page that everyone can read (fewer cliques): its
# members by rank, its leaders and its in-character board. Staff tick a
# group's leaders; leaders and staff set its list of ranks and give members
# their rank. Only the group's characters post on its board.
class CharacterGroup < ApplicationRecord
  MAX_RANKS = 20
  RANK_LENGTH = 40

  has_many :characters, dependent: :nullify
  has_one :board, class_name: "ForumBoard", dependent: :destroy

  normalizes :name, with: ->(n) { n.squish }
  normalizes :colour, with: ->(c) { c.strip.downcase }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :colour, format: { with: /\A#\h{6}\z/, message: "must be a colour like #5b3f8c" }
  validates :description, length: { maximum: 300 }
  normalizes :wanted_note, with: ->(n) { n.squish.presence }
  validates :wanted_note, length: { maximum: 200 }

  validate :ranks_are_reasonable

  scope :ordered, -> { order(:position, :name) }

  # Staff who tick leaders and run every group.
  def self.staff?(account)
    account&.can?(:review_apps) || false
  end

  # The ranks, highest first, one per line as leaders type them.
  def rank_names
    ranks.to_s.lines.map(&:squish).compact_blank.uniq
  end

  # The group's characters everyone sees: approved, still played and not on
  # the roster.
  def members
    characters.active.where(status: "approved", on_roster_at: nil)
  end

  # Members in rank order: leaders first, then each rank in the list's order,
  # then everyone without a rank, by name within each.
  def members_by_rank
    order = rank_names
    members.includes(:account, icon_attachment: :blob).sort_by do |character|
      [ character.group_leader? ? 0 : 1, order.index(character.group_rank) || order.size, character.name.downcase ]
    end
  end

  def leader_account?(account)
    account.present? && members.where(group_leader: true, account_id: account.id).exists?
  end

  # Leaders and staff set the ranks and give members their rank.
  def manageable_by?(account)
    self.class.staff?(account) || leader_account?(account)
  end

  # The group's in-character board, made the first time it's needed.
  def board!
    board || create_board!(name: "#{name} board", in_character: true,
      who_can_start: "group_members", who_can_reply: "group_members",
      description: "In-character posts from #{name}. Everyone can read it; only its members post.")
  rescue ActiveRecord::RecordNotUnique
    reload.board
  end

  private
    def ranks_are_reasonable
      names = rank_names
      errors.add(:ranks, "can have at most #{MAX_RANKS}") if names.size > MAX_RANKS
      errors.add(:ranks, "must each be #{RANK_LENGTH} characters or fewer") if names.any? { |name| name.length > RANK_LENGTH }
    end
end
