# The Looking for RP flag: on until the player switches it off. The list
# leaves out characters whose player hasn't been around for a while, so
# a forgotten flag doesn't send people chasing someone who's gone.
module Character::LookingForRp
  extend ActiveSupport::Concern

  TAG_LENGTH = 100
  # Characters whose player hasn't been seen for this long drop off the list.
  STALE_AFTER = 7.days

  included do
    normalizes :lfrp_i_am, :lfrp_looking_for, with: ->(value) { value.strip.presence }
    validates :lfrp_i_am, :lfrp_looking_for, length: { maximum: TAG_LENGTH }

    scope :looking_for_rp, -> { active.where.not(lfrp_at: nil) }
    scope :looking_for_rp_now, -> {
      looking_for_rp.joins(:account).where(accounts: { last_seen_at: STALE_AFTER.ago.. })
    }
  end

  def looking_for_rp? = lfrp_at.present? && can_play?

  def look_for_rp!(i_am: nil, looking_for: nil)
    update!(lfrp_at: Time.current, lfrp_i_am: i_am, lfrp_looking_for: looking_for)
  end

  # The "Looking for a scene" nudge: one quiet alert (the bell only, no
  # email) to every other player with a character on the list. A player
  # can nudge once every NUDGE_EVERY. Returns how many players were told.
  NUDGE_EVERY = 3.hours

  def nudgeable?
    looking_for_rp? && (account.lfrp_nudged_at.nil? || account.lfrp_nudged_at <= NUDGE_EVERY.ago)
  end

  def nudge_everyone_looking!
    return 0 unless nudgeable?
    account.update!(lfrp_nudged_at: Time.current)
    accounts = Account.where(id: Character.looking_for_rp_now.where.not(account_id: account_id).select(:account_id))
    accounts.each { |other| Alert.notify!(other, "lfrp_nudge", character: self, note: lfrp_looking_for) }
    accounts.size
  end

  def stop_looking_for_rp!
    update!(lfrp_at: nil)
  end
end
