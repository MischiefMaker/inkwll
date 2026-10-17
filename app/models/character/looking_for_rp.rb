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

  def stop_looking_for_rp!
    update!(lfrp_at: nil)
  end
end
