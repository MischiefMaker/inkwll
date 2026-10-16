# Starting an Inkling from a Chapter, or linking one you already have to it.
# Only a character in the Chapter can do this, and only with their own Inklings.
class Scenes::InklingLinksController < ApplicationController
  limit_posting to: 10
  before_action :require_inklings
  before_action :find_scene_and_character

  def create
    inkling = if params[:inkling_id].present?
      Inkling.where(character: @character).find(params[:inkling_id])
    else
      Inkling.start!(character: @character, by: current_account, kind: params[:kind].to_s, title: params[:title], body: params[:body])
    end
    InklingSceneLink.find_or_create_by!(inkling: inkling, scene: @scene) { |link| link.linked_by = current_account }
    redirect_to @scene, notice: "Linked #{inkling.title} to this #{Term[:scene].downcase}."
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to @scene, alert: e.message
  end

  def destroy
    link = InklingSceneLink.where(scene: @scene, inkling: Inkling.where(character: @character)).find(params[:id])
    link.destroy
    redirect_to @scene, notice: "Unlinked."
  end

  private
    def require_inklings
      raise ActiveRecord::RecordNotFound unless Inkling.enabled?
    end

    def find_scene_and_character
      @scene = Scene.find(params[:scene_id])
      raise ActiveRecord::RecordNotFound unless @scene.visible_to?(current_account)
      @character = @scene.participants_for(current_account).map(&:character).find { |c| c.id == current_character&.id }
      redirect_to(@scene, alert: "Your character isn't in this #{Term[:scene].downcase}.") unless @character
    end
end
