# The game's catalogue of Boons and Banes.
class Admin::SoulBnbsController < Admin::BaseController
  require_job :review_apps
  before_action :set_bnb, only: %i[ edit update destroy ]

  def index
    @bnbs = Soul::Bnb.ordered
    @bnb = Soul::Bnb.new(kind: "boon")
  end

  def create
    @bnb = Soul::Bnb.new(bnb_params)
    if @bnb.save
      Soul::AuditEntry.record!("catalogue_add", "Added #{@bnb.label} to the catalogue", actor: current_account)
      redirect_to admin_soul_bnbs_path, notice: "#{@bnb.name} added."
    else
      @bnbs = Soul::Bnb.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  # Entries are retired (made inactive) rather than deleted, since
  # characters may hold them.
  def update
    if @bnb.update(bnb_params)
      Soul::AuditEntry.record!("catalogue_change", "Changed #{@bnb.label} in the catalogue", actor: current_account)
      redirect_to admin_soul_bnbs_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Deletes an entry no character holds. One that characters hold is
  # retired instead, so their sheets keep it.
  def destroy
    if @bnb.character_bnbs.exists?
      @bnb.update!(active: false)
      Soul::AuditEntry.record!("catalogue_change", "Retired #{@bnb.label} from the catalogue", actor: current_account)
      redirect_to admin_soul_bnbs_path, notice: "Characters already have #{@bnb.name}, so it was retired instead: nobody new can pick it, and their sheets keep it."
    else
      @bnb.destroy!
      Soul::AuditEntry.record!("catalogue_remove", "Deleted #{@bnb.label} from the catalogue", actor: current_account)
      redirect_to admin_soul_bnbs_path, notice: "#{@bnb.name} deleted."
    end
  end

  private
    def set_bnb
      @bnb = Soul::Bnb.find(params[:id])
    end

    def bnb_params
      permitted = params.expect(soul_bnb: [ :kind, :name, :description, :starting, :active, skill_ids: [] ])
      permitted[:skill_ids] = Array(permitted[:skill_ids]).compact_blank.map(&:to_i) if permitted.key?(:skill_ids)
      permitted
    end
end
