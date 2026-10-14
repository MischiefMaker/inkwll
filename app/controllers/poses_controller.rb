# Posting, editing and removing Passages (poses) in a Chapter.
class PosesController < ApplicationController
  before_action :require_character
  before_action :set_scene
  before_action :set_own_pose, only: %i[ edit update destroy ]

  # Posting out of turn needs a second click ("Post anyway"); the page asks
  # first, and this double-checks in case the turn moved in the meantime.
  def create
    participant = @scene.participant_for(current_character)
    if participant && @scene.out_of_turn?(participant) && params[:post_anyway] != "1"
      return redirect_to @scene, alert: "It's #{@scene.current_turn_participant.character.name}'s turn. Post again to post anyway."
    end

    @scene.post!(current_character, params.expect(pose: [ :body ])[:body])
    redirect_to @scene
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to @scene, alert: e.message
  end

  def edit
  end

  def update
    @pose.edit!(params.expect(pose: [ :body ])[:body])
    redirect_to scene_path(@scene, anchor: dom_id(@pose))
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @pose.remove!
    redirect_to @scene
  end

  private
    def set_scene
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.readable_by?(current_account)
    end

    # Players can only change their own Passages.
    def set_own_pose
      @pose = @scene.poses.passage.where(character: current_account.characters).find(params[:id])
    end

    def dom_id(record)
      ActionView::RecordIdentifier.dom_id(record)
    end
end
