class CharactersController < ApplicationController
  limit_posting to: 5, within: 10.minutes
  before_action :set_own_character, only: %i[ edit update ]

  def index
    @characters = current_account.characters.includes(:room).order(:name)
  end

  def show
    @character = Character.find(params[:id])
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
      params.expect(character: [ :name, :description, :icon, :remove_icon ])
    end
end
