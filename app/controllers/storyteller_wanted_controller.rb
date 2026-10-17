# Open Chapters whose players asked for a Storyteller, for players with the
# Storyteller flag (and staff) to pick one up.
class StorytellerWantedController < ApplicationController
  before_action { raise ActiveRecord::RecordNotFound unless current_account.may_storytell? }

  def index
    @scenes = Scene.storyteller_wanted.includes(:room, participants: :character).order(:storyteller_wanted_at).limit(200)
  end
end
