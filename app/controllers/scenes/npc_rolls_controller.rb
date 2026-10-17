# The Storyteller rolling (or casting a spell) for an NPC in a Chapter. The result is posted for everyone.
class Scenes::NpcRollsController < ApplicationController
  include SoulRequired
  limit_posting to: 10

  def create
    scene = Scene.find(params[:scene_id])
    raise ActiveRecord::RecordNotFound unless scene.visible_to?(current_account)
    character = scene.participants_for(current_account).detect(&:storyteller?)&.character or
      return redirect_to(scene, alert: "Only the #{Term[:storyteller]} can roll for an NPC.")
    spell = Grimoire::Spell.active.find(params[:spell_id]) if params[:spell_id].present?
    scene.npc_roll!(character, npc_name: params[:npc_name], rating: params[:rating], difficulty_name: params[:difficulty], spell: spell)
    redirect_to scene
  rescue ArgumentError => e
    redirect_to scene, alert: e.message
  end
end
