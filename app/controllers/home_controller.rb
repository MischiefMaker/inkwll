# The front page: the game's name and blurb, then its top-level Areas.
# "Enter" takes the character to an Area's entrance Setting, and players walk
# the Paths from there.
class HomeController < ApplicationController
  def show
    @areas = Area.top_level.with_attached_image.with_attached_icon
    # The character each player seen in the last few minutes is playing.
    @online = Character.active.where(id: Account.where(last_seen_at: 10.minutes.ago..).select(:active_character_id))
      .includes(:character_group).order(:name)
  end
end
