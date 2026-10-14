# Adding, changing and deleting SOUL Skills.
class Admin::SoulSkillsController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_record, only: %i[ edit update destroy ]

  def create
    @record = Soul::Skill.new(record_params)
    @record.position = Soul::Skill.where(soul_aspect_id: @record.soul_aspect_id).maximum(:position).to_i + 1
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

  # Every character's rating in it is deleted too, and old rolls keep its name.
  def destroy
    if @record.destroy
      redirect_to admin_soul_path, notice: "#{@record.name} deleted."
    else
      redirect_to admin_soul_path, alert: @record.errors.full_messages.to_sentence
    end
  end

  private
    def set_record
      @record = Soul::Skill.find(params[:id])
    end

    def record_params
      params.expect(soul_skill: [ :name, :description, :soul_aspect_id, :position ])
    end
end
