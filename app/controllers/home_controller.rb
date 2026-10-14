# The front page: the game's top-level Areas, like the boards on a forum.
class HomeController < ApplicationController
  def show
    @areas = Area.top_level.includes(:children, rooms: :characters)
  end
end
