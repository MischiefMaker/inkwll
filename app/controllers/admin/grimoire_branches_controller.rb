# Adding and changing branches of magic. A branch with spells can't be deleted.
class Admin::GrimoireBranchesController < Admin::BaseController
  include GrimoireRequired
  require_job :review_apps
  before_action :set_branch, only: %i[ edit update destroy ]

  def create
    branch = Grimoire::Branch.new(branch_params.merge(position: Grimoire::Branch.maximum(:position).to_i + 1))
    if branch.save
      redirect_to admin_grimoire_path, notice: "#{branch.name} added."
    else
      redirect_to admin_grimoire_path, alert: branch.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @branch.update(branch_params)
      redirect_to admin_grimoire_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @branch.destroy
      redirect_to admin_grimoire_path, notice: "#{@branch.name} deleted."
    else
      redirect_to admin_grimoire_path, alert: "#{@branch.name} still has spells, so it can't be deleted."
    end
  end

  private
    def set_branch
      @branch = Grimoire::Branch.find(params[:id])
    end

    def branch_params
      params.expect(grimoire_branch: [ :name, :description, :soul_skill_id, :position ])
    end
end
