# The Where list, like a MUSH's `where` command: which Setting every
# character is standing in, and the open Chapters they're taking part in.
# Private and hidden Chapters never show here.
class WhereController < ApplicationController
  allow_previews

  def show
    @characters = Character.active.includes(room: :area).order(:name)
    @open_scenes = SceneParticipant.joins(:scene).merge(Scene.visibility_joinable).merge(Scene.active)
      .includes(scene: :room).group_by(&:character_id)
  end
end
