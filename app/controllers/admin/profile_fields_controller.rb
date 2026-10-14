# The game's profile and application fields for characters.
class Admin::ProfileFieldsController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_field, only: %i[ edit update destroy ]

  def index
    @fields = ProfileField.ordered.group_by(&:section)
    @field = ProfileField.new
  end

  def create
    @field = ProfileField.new(field_params)
    @field.position = ProfileField.where(section: @field.section).maximum(:position).to_i + 1
    if @field.save
      redirect_to admin_profile_fields_path, notice: "#{@field.name} added."
    else
      @fields = ProfileField.ordered.group_by(&:section)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @field.update(field_params)
      redirect_to admin_profile_fields_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Deleting a field also deletes what every character wrote in it.
  def destroy
    @field.destroy
    redirect_to admin_profile_fields_path, notice: "#{@field.name} deleted."
  end

  private
    def set_field
      @field = ProfileField.find(params[:id])
    end

    def field_params
      params.expect(profile_field: [ :name, :section, :field_type, :public, :required, :on_passages, :ask_on_roster, :hint, :position ])
    end
end
