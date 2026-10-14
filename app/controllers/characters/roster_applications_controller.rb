# Applying to take over a character on the roster. Any logged-in player can
# apply; staff pick who gets the character.
class Characters::RosterApplicationsController < ApplicationController
  limit_posting to: 5, within: 10.minutes
  before_action :set_roster_character

  def new
    @application = @character.roster_applications.new
  end

  def create
    @application = @character.roster_applications.new(account: current_account, note: params.expect(roster_application: [ :note ])[:note])
    if @application.save
      redirect_to @character, notice: "Applied to play #{@character.name}. Staff will let you know."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_roster_character
      @character = Character.on_roster.find(params[:character_id])
    end
end
