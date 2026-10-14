# Who can see an Inkling, and what they see.
#
# - Its character's player sees it all, except staff notes.
# - Characters it's shared with (one by one, or by character group) see it,
#   except private entries not meant for them.
# - App staff see it once it has been sent to them (or if staff started
#   it), including staff notes. Never a draft.
# - Personal notes are only ever seen by whoever wrote them.
module Inkling::Visibility
  extend ActiveSupport::Concern

  included do
    # The Inklings an account sees in its lists: its characters' own and
    # those shared with them. Staff find the rest on the admin page.
    scope :visible_to, ->(account) {
      characters = account.characters.active
      where(character_id: characters.select(:id))
        .or(where(id: InklingShare.where(character_id: characters.select(:id)).select(:inkling_id)))
        .or(where("inklings.shared_group_ids && ARRAY(?)::integer[]", characters.where.not(character_group_id: nil).select(:character_group_id)))
    }
  end

  def owned_by?(account) = character.account_id == account.id

  def staff_view?(account)
    staff_visible_at.present? && !owned_by?(account) && account.can?(:review_apps)
  end

  def shared_with?(account)
    mine = account.characters.active
    shares.where(character_id: mine.select(:id)).exists? ||
      (shared_group_ids.any? && mine.where(character_group_id: shared_group_ids).exists?)
  end

  def visible_to?(account)
    return false if account.nil?
    owned_by?(account) || staff_view?(account) || shared_with?(account)
  end

  # Writing new entries: its player and the characters it's shared with,
  # unless it's locked waiting for staff or closed; and staff.
  def writable_by?(account)
    return false if closed?
    staff_view?(account) || (!locked? && (owned_by?(account) || shared_with?(account)))
  end

  def entries_visible_to(account)
    entries.includes(:character, :account, :private_to, :soul_roll).select { |entry| entry.visible_to?(account) }
  end
end
