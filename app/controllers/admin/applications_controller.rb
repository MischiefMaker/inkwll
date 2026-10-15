# Staff reviewing submitted characters: approve, or return with a note.
class Admin::ApplicationsController < Admin::BaseController
  require_job :review_apps

  def index
    @waiting = Character.submitted.includes(:account).order(:submitted_at)
    @recent = Character.where(status: %w[ approved returned ]).where.not(reviewed_at: nil).includes(:reviewed_by).order(reviewed_at: :desc).limit(20)
  end

  def show
    @character = Character.includes(profile_values: :profile_field).find(params[:id])
    @tabs = { "answers" => "Application" }
    @tabs["soul"] = "SOUL" if Soul.enabled?
    @tabs["grimoire"] = "Grimoire" if Grimoire.enabled?
    @tabs.merge!("gallery" => "Gallery", "relationships" => "Relationships")
    @tab = params[:tab].presence_in(@tabs.keys) || "answers"
  end

  def update
    character = Character.submitted.find(params[:id])
    if params[:decision] == "approve"
      character.approve!(by: current_account)
      redirect_to admin_applications_path, notice: "#{character.name} approved."
    else
      character.return!(by: current_account, note: params[:note])
      redirect_to admin_applications_path, notice: "#{character.name} returned to their player."
    end
  end
end
