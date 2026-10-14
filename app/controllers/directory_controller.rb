# The character directory: every approved character being played, and the
# ones on the roster, filtered by a public profile field. /roster is the
# same page showing only the roster.
class DirectoryController < ApplicationController
  def index
    @fields = ProfileField.where(public: true).ordered
    @roster_only = params[:roster] == "1"
    @groups = CharacterGroup.ordered
    @group = @groups.find_by(id: params[:group])
    characters = Character.includes(:character_group, icon_attachment: :blob).order(:name)
    characters = characters.where(character_group: @group) if @group
    characters = @roster_only ? characters.on_roster :
      characters.where("(characters.status = 'approved' AND characters.retired_at IS NULL) OR characters.on_roster_at IS NOT NULL")

    @field = @fields.find_by(id: params[:field])
    @value = params[:value].to_s.strip.first(100)
    if @field && @value.present?
      characters = characters.where(id: ProfileValue.where(profile_field: @field)
        .where("value ILIKE ?", "%#{Character.sanitize_sql_like(@value)}%").select(:character_id))
    end
    @characters = characters.limit(500)
    @values = @field ? ProfileValue.where(profile_field: @field, character_id: @characters.map(&:id)).index_by(&:character_id) : {}
  end
end
