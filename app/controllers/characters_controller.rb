class CharactersController < ApplicationController
  limit_posting to: 5, within: 10.minutes
  limit_posting to: 20, within: 1.hour, only: :update, name: "uploads"
  before_action :set_own_character, only: %i[ edit update ]

  def index
    @characters = current_account.characters.includes(:room).order(:name)
  end

  # Profiles of characters still waiting for approval are only shown to
  # their player and staff.
  def show
    @character = Character.includes(profile_values: :profile_field).find(params[:id])
    @mine = @character.account_id == current_account.id
    @staff_view = current_account.staff?
    raise ActiveRecord::RecordNotFound unless @character.approved? || @mine || @staff_view
    tabs = %w[ profile application gallery relationships logs ]
    tabs << "soul" if Soul.enabled? && (@mine || @staff_view)
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
    if @character.update(character_params)
      redirect_to @character, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    # Players can only edit their own characters.
    def set_own_character
      @character = current_account.characters.find(params[:id])
    end

    def character_params
      params.expect(character: [ :name, :description, :icon, :remove_icon, profile: {} ])
    end
end
