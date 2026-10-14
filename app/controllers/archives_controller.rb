# The Archives: every finished Chapter (Manuscript) the player may read,
# newest first, optionally for one Setting or one character.
class ArchivesController < ApplicationController
  LIMIT = 100

  def index
    @scenes = Scene.finished.visible_to(current_account).includes(:room, participants: :character).order(finished_at: :desc)
    if params[:room_id].present?
      @room = Room.find(params[:room_id])
      @scenes = @scenes.where(room: @room)
    end
    if params[:character_id].present?
      @character = Character.find(params[:character_id])
      @scenes = @scenes.where(id: @character.scene_participants.select(:scene_id))
    end
    @scenes = @scenes.limit(LIMIT)
  end
end
