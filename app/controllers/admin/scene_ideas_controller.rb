# Ideas for Chapters that "Give me an idea" picks from at random.
class Admin::SceneIdeasController < Admin::BaseController
  require_job :build

  def index
    @ideas = SceneIdea.order(:title)
    @idea = SceneIdea.new
  end

  def create
    @idea = SceneIdea.new(params.expect(scene_idea: [ :title, :subtitle ]))
    if @idea.save
      redirect_to admin_scene_ideas_path, notice: "Idea added."
    else
      @ideas = SceneIdea.order(:title)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    SceneIdea.find(params[:id]).destroy
    redirect_to admin_scene_ideas_path, notice: "Idea deleted."
  end
end
