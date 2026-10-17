# A family, guild, club or other circle characters belong to. Unlike a
# character group (one per character, colours names), a character can be in
# many factions. Staff make factions; players pick the open ones on their
# application, and heads and staff add members after that.
#
# A secret faction is only seen by its members and staff. In any faction, a
# membership can be secret too: only that character's player, the faction's
# heads and staff see it. A head can be an NPC (just a name) or a character
# on the roster; staff run the faction for them, so games are nudged to give
# each faction several player heads. Faction Banks (see docs/economy.md) will hang off
# factions later.
class Faction < ApplicationRecord
  has_many :memberships, class_name: "FactionMembership", dependent: :delete_all
  has_many :characters, through: :memberships

  normalizes :name, with: ->(n) { n.squish }
  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 5000 }
  validates :npc_heads, length: { maximum: 300 }

  scope :ordered, -> { order(:position, :name) }
  # The factions a player can tick on their character's application.
  scope :pickable, -> { where(secret: false, pick_on_application: true) }

  def self.enabled?
    GameSetting.current.factions_enabled?
  end

  # Staff who see every faction and every membership, and manage them all.
  def self.staff?(account)
    account&.can?(:review_apps) || false
  end

  # The factions an account (or a guest, nil) can see.
  def self.visible_to(account)
    return all if staff?(account)
    return where(secret: false) unless account
    where(secret: false).or(where(id: FactionMembership.where(character_id: account.characters.active.select(:id)).select(:faction_id)))
  end

  def visible_to?(account)
    !secret? || self.class.staff?(account) || member_account?(account)
  end

  def member_account?(account)
    account.present? && memberships.where(character_id: account.characters.active.select(:id)).exists?
  end

  def head_account?(account)
    account.present? && memberships.where(head: true, character_id: account.characters.active.select(:id)).exists?
  end

  # The NPC heads' names, from the comma-separated list staff type in.
  def npc_head_names
    npc_heads.to_s.split(",").map(&:squish).compact_blank
  end

  # Whether a player (not staff) runs it: a head who is played and not on
  # the roster. Otherwise staff look after it.
  def player_heads?
    memberships.where(head: true).joins(:character).merge(Character.active.where(on_roster_at: nil, status: "approved")).exists?
  end

  # Heads and staff add, change and remove members.
  def manageable_by?(account)
    self.class.staff?(account) || head_account?(account)
  end

  # The members an account can see: approved characters still being played,
  # without secret memberships unless the account may see them.
  def visible_memberships_for(account)
    shown = memberships.joins(:character).merge(Character.active.where(status: "approved"))
      .includes(character: [ :character_group, { icon_attachment: :blob } ])
      .order(head: :desc).order("characters.name")
    return shown if manageable_by?(account)
    mine = account ? account.characters.select(:id) : []
    shown.where(secret: false).or(shown.where(character_id: mine))
  end
end
