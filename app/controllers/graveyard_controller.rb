# Characters who have died in the story, most recent first by game date.
class GraveyardController < ApplicationController
  allow_previews

  def index
    @characters = Character.played.deceased.includes(:character_group, icon_attachment: :blob).order(deceased_on: :desc, name: :asc).limit(500)
  end
end
