# Applying to take over a character on the roster. Any logged-in player can
# apply; staff pick who gets the character. Games that allow it let players
# claim a roster character straight away instead.
class Characters::RosterApplicationsController < ApplicationController
  limit_posting to: 5, within: 10.minutes
  before_action :set_roster_character

  def new
    @application = @character.roster_applications.new
  end

  def create
    claim = GameSetting.current.roster_claim?
    @application = @character.roster_applications.new(account: current_account, claim: claim,
      note: params.dig(:roster_application, :note).to_s, answers: params.dig(:roster_application, :answers)&.to_unsafe_h || {})
    if @application.save
      if claim
        @application.approve!(by: nil)
        notice = @character.reload.draft? ? "#{@character.name} is yours. Finish their application and send it to staff to start playing." : "#{@character.name} is yours to play."
        redirect_to @character, notice: notice
      else
        redirect_to @character, notice: "Applied to play #{@character.name}. Staff will let you know."
      end
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to @character, alert: "Someone else claimed #{@character.name} first."
  end

  private
    def set_roster_character
      @character = Character.on_roster.find(params[:character_id])
    end
end
