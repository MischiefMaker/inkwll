# The factions a character belongs to. On the character form, the player
# ticks the open factions they want until the character is approved; after
# that, heads and staff add them from the faction's page.
module Character::FactionMember
  extend ActiveSupport::Concern

  included do
    has_many :faction_memberships, dependent: :delete_all
    has_many :factions, through: :faction_memberships
    has_many :faction_requests, dependent: :delete_all

    # Ids from the form's tick boxes, or nil when the form didn't send them.
    attribute :picked_faction_ids
    after_save :save_picked_factions, unless: -> { picked_faction_ids.nil? }
  end

  # The memberships an account can see, for the profile.
  def visible_faction_memberships_for(account)
    faction_memberships.joins(:faction).includes(:faction).merge(Faction.ordered).select { |membership| membership.visible_to?(account) }
  end

  private
    # Only the open factions are touched, so memberships heads or staff
    # added in other factions stay.
    def save_picked_factions
      pickable = Faction.pickable.pluck(:id)
      wanted = Array(picked_faction_ids).map(&:to_i) & pickable
      faction_memberships.where(faction_id: pickable - wanted).delete_all
      (wanted - faction_memberships.pluck(:faction_id)).each { |id| faction_memberships.create!(faction_id: id) }
      self.picked_faction_ids = nil
    end
end
