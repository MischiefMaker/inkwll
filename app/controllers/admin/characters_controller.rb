# Character list for staff. Characters are never deleted: Wellkeepers can
# retire one (it can't be played, but its Passages and Manuscripts stay) and
# bring it back.
class Admin::CharactersController < Admin::BaseController
  require_job :delete_characters
  before_action :set_character, only: %i[ update retire unretire ]

  PER_PAGE = 100

  def index
    scope = Character.played
    @pages = [ (scope.count / PER_PAGE.to_f).ceil, 1 ].max
    @page = params[:page].to_i.clamp(1, @pages)
    @characters = scope.includes({ account: { icon_attachment: :blob } }, :room).order(:retired_at, :name)
      .offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @groups = CharacterGroup.ordered
  end

  # Changing a character's group.
  def update
    group = CharacterGroup.find_by(id: params.dig(:character, :character_group_id).presence)
    @character.update!(character_group: group)
    redirect_to admin_characters_path, notice: "#{@character.name} is now in #{group&.name || "no group"}."
  end

  def retire
    @character.retire!
    Soul::AuditEntry.record!("retire", "Retired #{@character.name}", actor: current_account, character: @character)
    redirect_to admin_characters_path, notice: "#{@character.name} has been retired."
  end

  def unretire
    return redirect_to(admin_roster_path, alert: "#{@character.name} is on the roster. Approve an application to bring them back.") if @character.on_roster?
    return redirect_to(admin_characters_path, alert: "#{@character.name} was a roster character. Use Put back on the roster.") if @character.roster_retired?
    @character.unretire!
    Soul::AuditEntry.record!("unretire", "Brought #{@character.name} back from retirement", actor: current_account, character: @character)
    redirect_to admin_characters_path, notice: "#{@character.name} is back in play."
  end

  private
    def set_character
      @character = Character.find(params[:id])
    end
end
