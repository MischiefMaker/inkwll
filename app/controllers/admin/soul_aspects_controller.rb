# Adding, changing and deleting SOUL Aspects.
class Admin::SoulAspectsController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_record, only: %i[ edit update destroy ]

  def create
    @record = Soul::Aspect.new(record_params)
    @record.position = Soul::Aspect.maximum(:position).to_i + 1
    if @record.save
      redirect_to admin_soul_path, notice: "#{@record.name} added."
    else
      redirect_to admin_soul_path, alert: @record.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @record.update(record_params)
      redirect_to admin_soul_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # An Aspect with Skills can't be deleted.
  def destroy
    if @record.destroy
      redirect_to admin_soul_path, notice: "#{@record.name} deleted."
    else
      redirect_to admin_soul_path, alert: @record.errors.full_messages.to_sentence
    end
  end

  private
    def set_record
      @record = Soul::Aspect.find(params[:id])
    end

    def record_params
      params.expect(soul_aspect: [ :name, :description, :position ])
    end
end
