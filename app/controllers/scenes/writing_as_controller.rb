# The "Writing as" switcher above a Chapter's Passage box: choose which of
# your characters writes. One already in this Chapter takes over at once. One
# that isn't gets a warning first (see scenes/_writing_as), so you don't
# bring a second character into a Chapter by accident.
class Scenes::WritingAsController < Scenes::BaseController
  def update
    character = current_account.character_for_choice(params[:character_id])

    if @scene.participant_for(character)
      current_account.update!(active_character: character)
      current_account.remember_character(character, @scene)
      redirect_to @scene
    else
      redirect_to scene_path(@scene, join: character.gm? ? "gm" : character.id)
    end
  end
end
