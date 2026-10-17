# Opens a Chapter for each calendar event whose time has come.
class EventStartJob < ApplicationJob
  def perform
    Event.open_due!
  end
end
