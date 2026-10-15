class CharactersController < ApplicationController
  limit_posting to: 5, within: 10.minutes
  limit_posting to: 20, within: 1.hour, only: :update, name: "uploads"
  before_action :set_own_character, only: %i[ edit update ]
  # Guests can read approved characters' profiles.
  allow_previews only: :show

  def index
    @characters = current_account.characters.played.includes(:room, :character_group, icon_attachment: :blob).order(:name)
  end

  # Profiles of characters still waiting for approval are only shown to
  # their player and staff.
  def show
    @character = Character.includes(profile_values: :profile_field).find(params[:id])
    return redirect_to player_path(@character.account.username) if @character.gm?
    @mine = current_account.present? && current_account.editable_characters.exists?(@character.id)
    @staff_view = current_account&.staff? || false
    raise ActiveRecord::RecordNotFound unless @character.approved? || @mine || @staff_view
    tabs = %w[ profile application gallery relationships logs ]
    tabs << "soul" if Soul.enabled? && (@mine || @staff_view)
    tabs << "grimoire" if Grimoire.enabled? && (@mine || @staff_view)
    @tab = params[:tab].presence_in(tabs) || "profile"
  end

  def new
    @character = current_account.characters.new
  end

  def create
    @character = current_account.characters.new(character_params)
    if @character.save
      current_account.switch_to(@character) unless current_character
      redirect_to @character, notice: "#{@character.name} has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @character.profile_editor = current_account
    if @character.update(character_params)
      redirect_to @character, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    # Players can only edit their own characters; staff can also edit roster
    # characters.
    def set_own_character
      @character = current_account.editable_characters.find(params[:id])
    end

    # Players pick a group until their character is approved; after that
    # only staff change it.
    def character_params
      permitted = [ :name, :icon, :remove_icon, :roster_when_idle, profile: {}, remove_profile_pictures: [] ]
      permitted.unshift(:character_group_id) if @character.nil? || @character.group_choosable?
      params.expect(character: permitted).tap do |attributes|
        if attributes.key?(:character_group_id) && !CharacterGroup.exists?(id: attributes[:character_group_id].presence)
          attributes[:character_group_id] = nil
        end
      end
    end
end
