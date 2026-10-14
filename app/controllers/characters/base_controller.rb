# Shared by the parts of a character's profile its player manages.
class Characters::BaseController < ApplicationController
  before_action :set_own_character

  private
    def set_own_character
      @character = current_account.characters.find(params[:character_id])
    end
end
