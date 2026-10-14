# Shared by the actions inside a Chapter (joining, turns, invitations...).
class Scenes::BaseController < ApplicationController
  before_action :set_scene

  private
    def set_scene
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
    end

    # The active character's place in this Chapter, if it's in it.
    def participant
      @participant ||= @scene.participant_for(current_character)
    end

    def require_participant
      redirect_to @scene, alert: "#{current_character&.name || "You"} isn't in this #{Term[:scene]}." unless participant
    end
end
