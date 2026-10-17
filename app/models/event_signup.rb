# A character signed up for an event on the calendar.
class EventSignup < ApplicationRecord
  belongs_to :event
  belongs_to :character

  validates :character_id, uniqueness: { scope: :event_id }
end
