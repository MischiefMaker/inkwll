# Chapters waiting for a staff ruling. Staff who handle reports read the
# Chapter and give a ruling, which is written into it.
class Admin::RulingsController < Admin::BaseController
  require_job :handle_reports
  limit_posting to: 20, within: 10.minutes, only: :update

  def index
    @scenes = Scene.ruling_wanted.includes(:room, participants: :character).order(:ruling_wanted_at)
  end

  def update
    scene = Scene.ruling_wanted.find(params[:id])
    if scene.give_ruling!(by: current_account, ruling: params[:ruling])
      redirect_to admin_rulings_path, notice: "Ruling posted in #{scene.title}."
    else
      redirect_to admin_rulings_path, alert: "Write the ruling first."
    end
  end
end
