# What is waiting on a staff member to look at, limited to the kinds of work
# their jobs allow: applications, roster requests, SOUL requests, Inklings
# sent to staff, Grimoire spell proposals, requests to join factions and
# reports. The admin menu and
# the bell's drop-down both read from here.
module StaffWaiting
  Item = Struct.new(:key, :label, :count, keyword_init: true)

  def self.for(account)
    return [] unless account&.staff?
    items = []
    if account.can?(:review_apps)
      items << Item.new(key: :applications, label: "Applications", count: Character.submitted.count)
      items << Item.new(key: :roster, label: "Roster requests", count: RosterApplication.pending.count + Character.active.where.not(roster_requested_at: nil).count)
      items << Item.new(key: :soul, label: "SOUL requests", count: Soul::BnbRequest.pending.count + Soul::Culmination.proposed.count + Soul::AwardSuggestion.pending.count) if Soul.enabled?
      items << Item.new(key: :inklings, label: "Inklings", count: Inkling.submitted.open.count) if Inkling.enabled?
      items << Item.new(key: :grimoire, label: "Spell proposals", count: Grimoire::Proposal.pending.count) if Grimoire.enabled?
      items << Item.new(key: :factions, label: "#{Term[:faction]} requests", count: FactionRequest.pending.count) if Faction.enabled?
    end
    items << Item.new(key: :players, label: "New players", count: Account.waiting_for_approval.count) if account.can?(:manage_staff) && GameSetting.current.player_approval_required?
    items << Item.new(key: :reports, label: "Reports", count: Report.unresolved.count) if account.can?(:handle_reports)
    items
  end

  # Refreshes the bell on every staff member's open pages.
  def self.refresh_bells!
    Account.where.not(staff_level: "player").find_each(&:broadcast_alert_count)
  end

  # Only the items with something waiting.
  def self.pending_for(account)
    self.for(account).select { |item| item.count.positive? }
  end

  def self.total_for(account)
    pending_for(account).sum(&:count)
  end

  def self.count(account, key)
    self.for(account).find { |item| item.key == key }&.count.to_i
  end
end
