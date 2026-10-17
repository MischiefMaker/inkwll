# The NPCs page: the game's recurring NPCs, with their pictures and
# descriptions. Staff and Storytellers also see the notes and SOUL ratings.
class NpcsController < ApplicationController
  allow_previews

  def index
    @npcs = Npc.ordered.with_attached_icon
    @secrets = Npc.secrets_for?(current_account)
  end
end
