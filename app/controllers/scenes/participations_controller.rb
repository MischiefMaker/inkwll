# Joining and leaving a Chapter, and taking or dropping the storyteller role.
class Scenes::ParticipationsController < Scenes::BaseController
  before_action :require_character
  before_action :require_participant, only: %i[ update destroy ]

  # Joining from elsewhere walks the character over first ("Travel here and
  # join"), so characters are always where their new Chapter is.
  def create
    switch_to_chosen_character
    unless current_character.can_play?
      return redirect_to @scene, alert: "#{current_character.name} #{Scene::NOT_APPROVED}."
    end
    unless @scene.can_join?(current_character)
      return redirect_to @scene, alert: "#{current_character.name} can't join this #{Term[:scene]}."
    end

    current_character.update!(room: @scene.room) unless current_character.room_id == @scene.room_id
    @scene.join!(current_character)
    current_account.remember_character(current_character, @scene)
    redirect_to @scene
  end

  def update
    role = participant.storyteller? ? "player" : "storyteller"
    if participant.update(role: role)
      redirect_to @scene
    else
      redirect_to @scene, alert: participant.errors.full_messages.to_sentence
    end
  end

  def destroy
    @scene.leave!(current_character)
    redirect_to room_path(@scene.room), notice: "#{current_character.name} left #{@scene.title}."
  end

  private
    # The warning in "Writing as" offers to join as a different character of
    # yours than the one on screen.
    def switch_to_chosen_character
      return if params[:character_id].blank?
      current_account.update!(active_character: current_account.characters.active.find(params[:character_id]))
    end
end
