# Players of a finished hidden Chapter agreeing (or not) to make it public.
# It becomes public only once every one of them agrees.
class Scenes::PublicConsentsController < Scenes::BaseController
  before_action :require_character, :require_participant

  def create
    @scene.consent_to_public!(participant)
    redirect_to @scene
  end

  def destroy
    @scene.consent_to_public!(participant, agree: false)
    redirect_to @scene
  end
end
