# The front page: the game's top-level Areas. Opening one takes you to its
# entrance Setting, and players walk the Paths from there.
class HomeController < ApplicationController
  def show
    @areas = Area.top_level.with_attached_image
    # The character each player seen in the last few minutes is playing.
    @online = Character.active.where(id: Account.where(last_seen_at: 10.minutes.ago..).select(:active_character_id))
      .includes(:character_group).order(:name)
  end
end
