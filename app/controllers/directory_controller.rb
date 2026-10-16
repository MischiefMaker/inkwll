# The character directory, in tabs: Active (approved characters being
# played), one tab per character group, then apart from those the Roster and,
# for staff, the characters not approved yet. A public profile field filters
# whichever tab is open. /roster is the same page on the Roster tab.
class DirectoryController < ApplicationController
  allow_previews

  def index
    @fields = ProfileField.where(public: true).where.not(field_type: "image").ordered
    @roster_only = params[:roster] == "1"
    @unapproved = params[:unapproved] == "1" && current_account&.staff?
    @groups = CharacterGroup.ordered
    @group = @groups.find_by(id: params[:group]) unless @roster_only || @unapproved
    characters = Character.played.includes(:character_group, icon_attachment: :blob).order(:name)
    characters = characters.where(character_group: @group) if @group
    characters =
      if @roster_only then characters.on_roster
      elsif @unapproved then characters.active.where.not(status: "approved")
      else characters.where(status: "approved", retired_at: nil, on_roster_at: nil)
      end

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
