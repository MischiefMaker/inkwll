# Chapters (scenes): starting one where your character stands, reading one,
# and changing its settings.
class ScenesController < ApplicationController
  # Guests can read the Chapters anyone may read, live or in the Archives.
  allow_previews only: %i[ index show ]
  before_action :require_character, only: :create
  before_action :set_scene, only: %i[ show edit update ]
  before_action :require_participant, only: %i[ edit update ]
  before_action :require_writable, only: %i[ edit update ]

  PER_PAGE = 30

  # Every Chapter that isn't Hidden, newest activity first. Closed ones are
  # listed too, but only linked for people who may read them. A Hidden one
  # shows only to the players in it.
  def index
    scenes = Scene.where.not(visibility: :hidden)
    scenes = scenes.or(Scene.where(id: SceneParticipant.where(character_id: current_account.characters.select(:id)).select(:scene_id))) if current_account
    scenes = scenes.where(finished_at: nil) if params[:show] == "open"
    scenes = scenes.where.not(finished_at: nil) if params[:show] == "finished"
    @show = params[:show].presence_in(%w[ open finished ])
    @pages = [ (scenes.count / PER_PAGE.to_f).ceil, 1 ].max
    @page = params[:page].to_i.clamp(1, @pages)
    @scenes = scenes.by_activity.includes(:room, participants: :character)
      .offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def show
    return unless current_account
    use_character_in_scene
    @participant = @scene.participant_for(current_character)
    Alert.read_for!(current_account, @scene)
  end

  def create
    @scene = Scene.start!(character: current_character, storyteller: params.dig(:scene, :storyteller) == "1", **scene_params)
    redirect_to @scene
  rescue ActiveRecord::RecordInvalid => e
    redirect_to room_path(current_character.room), alert: e.record.errors.full_messages.to_sentence
  rescue ArgumentError => e
    redirect_to room_path(current_character.room), alert: e.message
  end

  def edit
  end

  def update
    if @scene.update(scene_params)
      if params.dig(:scene, :ic_date) || params.dig(:scene, :ic_time)
        by = @scene.participants_for(current_account).first.character
        @scene.change_ic_date!(by: by, date: params.dig(:scene, :ic_date), time: params.dig(:scene, :ic_time))
      end
      redirect_to @scene, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  private
    def set_scene
      @scene = Scene.includes(participants: { character: [ :account, { icon_attachment: :blob } ] }).find(params[:id])
      raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
    end

    def require_participant
      redirect_to @scene, alert: "Only characters in this #{Term[:scene]} can change it." unless @scene.participating?(current_account)
    end

    # A new Chapter takes its date here; later changes go through
    # Scene#change_ic_date! so the Chapter gets a line about it.
    def scene_params
      permitted = [ :title, :subtitle, :visibility, :pose_mode, :auto_skip, :turn_minutes, label_ids: [] ]
      permitted.unshift(:ic_date, :ic_time) if action_name == "create"
      params.expect(scene: permitted)
    end

    # Like Settings, a Chapter remembers which of the player's characters they
    # last used in it. If the active character isn't in this Chapter but
    # another of the player's characters is, switch to that one.
    def use_character_in_scene
      mine = @scene.participants_for(current_account).map(&:character)
      return if mine.empty?

      if mine.include?(current_character)
        current_account.remember_character(current_character, @scene)
      else
        remembered = current_account.remembered_character_for(@scene)
        current_account.update!(active_character: mine.include?(remembered) ? remembered : mine.first)
      end
    end

    # Finished and locked Chapters can't be changed.
    def require_writable
      redirect_to @scene, alert: "This #{Term[:scene]} can't be changed now." unless @scene.writable?
    end
end
