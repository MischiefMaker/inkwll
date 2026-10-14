# A player submitting their character for staff approval.
class Characters::SubmissionsController < Characters::BaseController
  def create
    if @character.submit!
      redirect_to @character, notice: "Submitted. Staff will take a look."
    else
      redirect_to @character, alert: "#{@character.name} can't be submitted yet."
    end
  end
end
