# Rolls waiting for the Storyteller: the Storyteller calls for them or a
# player asks, the Storyteller judges and rolls them, and the player can
# cancel.
class Scenes::PendingRollsController < ApplicationController
  include SoulRequired
  limit_posting to: 20, only: :create
  before_action :set_pending, except: :create

  # The Storyteller calls for a roll from a player in the Chapter.
  def create
    @scene = Scene.find(params[:scene_id])
    raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
    by = @scene.participants_for(current_account).find(&:storyteller?)&.character or return head :forbidden
    character = @scene.participants.map(&:character).find { |c| c.id == params[:character_id].to_i } or
      return redirect_to(@scene, alert: "Pick a character in this #{Term[:scene]}.")
    rulings = params[:rulings].respond_to?(:to_unsafe_h) ? params[:rulings].to_unsafe_h : {}
    @scene.call_roll!(character, Soul::Skill.find(params[:skill_id]), params[:difficulty], by: by,
      mandatory_ids: rulings.select { |_, v| v == "must" }.keys, optional_ids: rulings.select { |_, v| v == "choice" }.keys)
    redirect_to @scene
  rescue ArgumentError => e
    redirect_to @scene, alert: e.message
  end

  # A waiting roll is ruled on by the Storyteller; a ready one is rolled by
  # its player, who picks from the Boons and Banes the Storyteller allowed.
  def update
    if @pending.ready?
      return head :forbidden unless @pending.character.account_id == current_account.id
      @scene.finish_roll!(@pending, bnb_ids: params[:bnb_ids])
    else
      by = @scene.participants_for(current_account).find(&:storyteller?)&.character or return head :forbidden
      rulings = params[:rulings].respond_to?(:to_unsafe_h) ? params[:rulings].to_unsafe_h : {}
      @scene.judge_roll!(@pending, by: by, difficulty_name: params[:difficulty],
        mandatory_ids: rulings.select { |_, v| v == "must" }.keys, optional_ids: rulings.select { |_, v| v == "choice" }.keys)
    end
    redirect_to @scene
  rescue ArgumentError, Character::SoulSheet::SheetError => e
    redirect_to @scene, alert: e.message
  end

  def destroy
    allowed = @pending.character.account_id == current_account.id || @scene.participants_for(current_account).any?(&:storyteller?)
    return head :forbidden unless allowed
    @scene.cancel_pending_roll!(@pending)
    redirect_to @scene, notice: "Roll cancelled."
  end

  private
    def set_pending
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
      @pending = @scene.pending_rolls.find(params[:id])
    end
end
