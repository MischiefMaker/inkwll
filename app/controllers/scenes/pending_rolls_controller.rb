# Rolls waiting for the Storyteller: the Storyteller judges and rolls them,
# and the player who asked can cancel.
class Scenes::PendingRollsController < ApplicationController
  include SoulRequired
  before_action :set_pending

  def update
    by = @scene.participants_for(current_account).find(&:storyteller?)&.character or return head :forbidden
    @scene.judge_roll!(@pending, by: by, difficulty_name: params[:difficulty], bnb_ids: params[:bnb_ids])
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
