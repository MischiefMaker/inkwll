# Rolling a SOUL Skill in a Chapter. The result is posted for everyone.
class Scenes::RollsController < ApplicationController
  include SoulRequired
  limit_posting to: 10

  before_action :set_scene_and_character

  def create
    skill = Soul::Skill.find(params[:skill_id])
    scene = @scene
    character = @character
    if params[:ask_storyteller] == "1"
      scene.ask_storyteller_to_roll!(character, skill, params[:difficulty])
      redirect_to scene, notice: "Asked the #{Term[:storyteller]}. Your roll happens when they judge it."
    else
      chosen = params[:confirmed] == "1" ? character.active_bnbs.select { |entry| Array(params[:bnb_ids]).map(&:to_i).include?(entry.id) } : nil
      scene.roll!(character, skill, params[:difficulty], bnbs: chosen)
      redirect_to scene
    end
  rescue ArgumentError => e
    redirect_to @scene, alert: e.message
  end

  private
    def set_scene_and_character
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
      @character = @scene.participants_for(current_account).map(&:character).find { |c| c.id == current_character&.id } or
        redirect_to(@scene, alert: "Your character isn't in this #{Term[:scene]}.")
    end
end
