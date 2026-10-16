# Adding a Chapter to an Inkling: the player says why, and the Inkling gets a
# new entry with the reason and a link to the Chapter. Works for Chapters
# still being written and for finished ones read in the Archives. Only a
# character in the Chapter can do this, and only in their own Inklings (or
# ones shared with them).
class Scenes::InklingLinksController < ApplicationController
  limit_posting to: 10
  before_action :require_inklings
  before_action :find_scene_and_character

  def create
    inkling = if params[:inkling_id].present?
      Inkling.visible_to(current_account).find(params[:inkling_id])
    else
      Inkling.start!(character: @character, by: current_account, kind: params[:kind].to_s, title: params[:title], body: nil)
    end
    raise ArgumentError, "You can't write in that Inkling." unless inkling.writable_by?(current_account) && !inkling.staff_view?(current_account)
    inkling.link_scene!(@scene, reason: params[:reason], by: current_account, character: @character)
    redirect_to @scene, notice: "Added this #{Term[:scene].downcase} to #{inkling.title}."
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to @scene, alert: e.message
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
