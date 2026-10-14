# Character list for staff. Characters are never deleted: Wellkeepers can
# retire one (it can't be played, but its Passages and Manuscripts stay) and
# bring it back.
class Admin::CharactersController < Admin::BaseController
  require_job :delete_characters
  before_action :set_character, only: %i[ retire unretire ]

  def index
    @characters = Character.includes(:account, :room).order(:retired_at, :name)
  end

  def retire
    @character.retire!
    Soul::AuditEntry.record!("retire", "Retired #{@character.name}", actor: current_account, character: @character)
    redirect_to admin_characters_path, notice: "#{@character.name} has been retired."
  end

  def unretire
    @character.unretire!
    Soul::AuditEntry.record!("unretire", "Brought #{@character.name} back from retirement", actor: current_account, character: @character)
    redirect_to admin_characters_path, notice: "#{@character.name} is back in play."
  end

  private
    def set_character
      @character = Character.find(params[:id])
    end
end
