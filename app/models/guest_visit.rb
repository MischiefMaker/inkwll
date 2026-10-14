# Where a visitor who isn't logged in is looking around (previewing), so a
# Setting's "Here" list can show "Guest" or "3 Guests". Each visitor counts
# in one Setting at a time, for GUEST_FOR after their last page view.
class GuestVisit < ApplicationRecord
  GUEST_FOR = 10.minutes
  # Search engines and link previews aren't guests.
  BOT = /bot|crawl|spider|slurp|preview|fetch|curl|wget|python|headless/i

  belongs_to :room

  scope :current, -> { where(seen_at: GUEST_FOR.ago..) }

  # Notes the visitor in this room. Tells the room's open pages to refresh
  # when a guest arrives, so the count stays live.
  def self.note!(token:, room:, user_agent:)
    return if token.blank? || user_agent.to_s.match?(BOT)
    where(seen_at: ...1.hour.ago).delete_all
    visit = find_or_initialize_by(token: token)
    arrived = visit.room_id != room.id || visit.seen_at.nil? || visit.seen_at < GUEST_FOR.ago
    visit.update!(room: room, seen_at: Time.current)
    room.broadcast_refresh_later if arrived
  end

  def self.count_in(room)
    current.where(room: room).count
  end
end
