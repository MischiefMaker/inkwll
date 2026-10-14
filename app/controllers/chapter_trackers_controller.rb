# "My Chapters": every open Chapter each of the player's characters is in,
# with its Setting, whose turn it is and who posted last.
class ChapterTrackersController < ApplicationController
  def show
    @participations = SceneParticipant.joins(:scene).merge(Scene.open.by_activity)
      .where(character: current_account.characters.active)
      .includes(:character, scene: [ :room, { current_turn_participant: :character } ])
      .group_by(&:character)
    scene_ids = @participations.values.flatten.map(&:scene_id)
    @last_posts = Pose.story.where(scene_id: scene_ids).includes(:character)
      .select("DISTINCT ON (poses.scene_id) poses.*").order(:scene_id, sequence: :desc).index_by(&:scene_id)
  end
end
