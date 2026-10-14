# The front page: the game's top-level Areas. Opening one takes you to its
# entrance Setting, and players walk the Paths from there.
class HomeController < ApplicationController
  def show
    @areas = Area.top_level.with_attached_image
  end
end
