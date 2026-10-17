# The world timeline: finished Chapters staff marked as world events, in the
# game's date order. Guests can read it; Chapters someone can't see are left
# out, and a Chapter's own summary only shows to those who can read it.
class TimelineController < ApplicationController
  allow_previews

  def index
    @events = Scene.world_events.visible_to(current_account).includes(:room, participants: :character)
  end
end
