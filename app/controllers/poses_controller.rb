# Posting, editing and removing Passages (poses) in a Chapter.
class PosesController < ApplicationController
  limit_posting to: 20
  before_action :require_character
  before_action :set_scene
  before_action :set_own_pose, only: %i[ edit update destroy ]
  before_action :require_writable, only: %i[ edit update destroy ]

  # Posting out of turn needs a second click ("Post anyway"); the page asks
  # first, and this double-checks in case the turn moved in the meantime.
  def create
    attributes = params.expect(pose: [ :body, :kind, :npc_name, :to ])
    kind = attributes[:kind].presence || "passage"
    participant = @scene.participant_for(current_character)
    if participant && Pose::TURN_KINDS.include?(kind) && @scene.out_of_turn?(participant) && params[:post_anyway] != "1"
      return redirect_to @scene, alert: "It's #{@scene.current_turn_participant.character.name}'s turn. Post again to post anyway."
    end

    @scene.post!(current_character, attributes[:body], kind: kind, npc_name: attributes[:npc_name], to: attributes[:to])
    redirect_to @scene
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to @scene, alert: e.message
  end

  def edit
  end

  def update
    @pose.edit!(params.expect(pose: [ :body ])[:body])
    redirect_to scene_path(@scene, anchor: dom_id(@pose), all: ("1" if @scene.before_live_page?(@pose)))
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

    # Players can only change their own Passages. Rolls can't be changed.
    def set_own_pose
      @pose = @scene.poses.where.not(kind: %w[ system roll ]).where(character: current_account.characters).find(params[:id])
    end

    # Nothing can be changed once a Chapter is finished or staff have locked it.
    def require_writable
      redirect_to @scene, alert: "This #{Term[:scene]} can't be changed now." unless @scene.writable?
    end

    def dom_id(record)
      ActionView::RecordIdentifier.dom_id(record)
    end
end
