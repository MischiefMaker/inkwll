# Labels players can put on their Chapters, such as content warnings.
# Deleting a label takes it off every Chapter.
class Admin::SceneLabelsController < Admin::BaseController
  require_job :change_game_settings
  before_action :set_label, only: %i[ edit update destroy ]

  def index
    @labels = SceneLabel.ordered
    @label = SceneLabel.new
  end

  def create
    @label = SceneLabel.new(label_params)
    @label.position = SceneLabel.maximum(:position).to_i + 1
    if @label.save
      redirect_to admin_scene_labels_path, notice: "#{@label.name} added."
    else
      @labels = SceneLabel.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @label.update(label_params)
      redirect_to admin_scene_labels_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @label.destroy
    redirect_to admin_scene_labels_path, notice: "#{@label.name} deleted."
  end

  private
    def set_label
      @label = SceneLabel.find(params[:id])
    end

    def label_params
      params.expect(scene_label: [ :name, :description, :position ])
    end
end
