# Rolling a SOUL Skill in a Chapter. The result is posted for everyone.
class Scenes::RollsController < ApplicationController
  include SoulRequired
  limit_posting to: 10

  def create
    scene = Scene.find(params[:scene_id])
    raise ActiveRecord::RecordNotFound unless scene.visible_to?(current_account)
    character = scene.participants_for(current_account).map(&:character).find { |c| c.id == current_character&.id } or
      return redirect_to(scene, alert: "Your character isn't in this #{Term[:scene]}.")

    scene.roll!(character, Soul::Skill.find(params[:skill_id]), params[:difficulty])
    redirect_to scene
  rescue ArgumentError => e
    redirect_to scene, alert: e.message
  end
end
