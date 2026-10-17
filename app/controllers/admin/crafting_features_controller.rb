# Adding and changing item features, and approving or declining the ones
# players propose.
class Admin::CraftingFeaturesController < Admin::BaseController
  include CraftingRequired
  require_job :review_apps
  before_action :set_feature, only: %i[ edit update destroy ]

  def create
    feature = Crafting::Feature.new(feature_params.merge(status: "approved"))
    if feature.save
      redirect_to admin_crafting_path, notice: "#{feature.name} added."
    else
      redirect_to admin_crafting_path, alert: feature.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  # Also approves or declines a proposal, with a reason for a decline.
  def update
    case params[:decision]
    when "approve"
      @feature.status = "approved"
    when "decline"
      @feature.assign_attributes(status: "declined", decline_reason: params[:reason].to_s.squish.first(300).presence)
    else
      @feature.assign_attributes(feature_params)
    end
    if @feature.save
      notify_proposer if params[:decision].present?
      redirect_to admin_crafting_path, notice: "#{@feature.name} #{params[:decision] == "decline" ? "declined" : "saved"}."
    else
      @feature.status = @feature.status_was
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feature.destroy
    redirect_to admin_crafting_path, notice: "#{@feature.name} deleted. Items that had it lose it."
  end

  private
    def set_feature
      @feature = Crafting::Feature.find(params[:id])
    end

    def feature_params
      params.expect(crafting_feature: [ :name, :description, :level, skill_ids: [], item_type_ids: [] ])
    end

    def notify_proposer
      character = @feature.proposed_by
      text = @feature.approved? ? "Staff approved the feature #{@feature.name}." : "Staff declined the feature #{@feature.name}#{": #{@feature.decline_reason}" if @feature.decline_reason}."
      Crafting.alert!(character, text) if character
    end
end
