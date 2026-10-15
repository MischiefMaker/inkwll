# Writing the guide to what SOUL ratings mean (shown behind the "i" icon on
# the sheet): adding, changing and deleting its lines.
class Admin::SoulRatingGuidesController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_record, only: %i[ edit update destroy ]

  def create
    @record = Soul::RatingGuide.new(record_params)
    @record.position = Soul::RatingGuide.maximum(:position).to_i + 1
    if @record.save
      Soul::AuditEntry.record!("catalogue_add", "Added #{@record.name} (#{@record.range_text}) to the rating guide", actor: current_account)
      redirect_to admin_soul_path(anchor: "rating-guide"), notice: "#{@record.name} added."
    else
      redirect_to admin_soul_path(anchor: "rating-guide"), alert: @record.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @record.update(record_params)
      Soul::AuditEntry.record!("catalogue_change", "Changed #{@record.name} in the rating guide", actor: current_account)
      redirect_to admin_soul_path(anchor: "rating-guide"), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy!
    Soul::AuditEntry.record!("catalogue_remove", "Deleted #{@record.name} from the rating guide", actor: current_account)
    redirect_to admin_soul_path(anchor: "rating-guide"), notice: "#{@record.name} deleted."
  end

  private
    def set_record
      @record = Soul::RatingGuide.find(params[:id])
    end

    def record_params
      params.expect(soul_rating_guide: [ :low, :high, :name, :description ])
    end
end
