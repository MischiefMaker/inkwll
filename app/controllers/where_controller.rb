# The Where list, like a MUSH's `where` command: which Setting every
# character is standing in, and the open Chapters they're taking part in.
# Private and hidden Chapters never show here.
class WhereController < ApplicationController
  def show
    @characters = Character.includes(:room).order(:name)
    @open_scenes = SceneParticipant.joins(:scene).merge(Scene.visibility_joinable).merge(Scene.active)
      .includes(scene: :room).group_by(&:character_id)
  end
end
