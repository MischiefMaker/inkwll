# Characters with a birthday this month, by the game's in-character date.
# Only shown when the game has a Birthday profile field.
class BirthdaysController < ApplicationController
  allow_previews

  def index
    field = ProfileField.find_by(field_type: "birthday")
    raise ActiveRecord::RecordNotFound unless field
    @today = IcClock.today
    month = format("%02d", @today.month)
    values = ProfileValue.where(profile_field: field).where("value LIKE ?", "____-#{month}-__")
      .joins(:character).merge(Character.active.where(status: "approved"))
      .includes(character: [ :character_group, :account, { icon_attachment: :blob } ])
    @birthdays = values.filter_map { |value| (date = value.as_date) && [ date, value.character ] }
      .sort_by { |date, character| [ date.day, character.name ] }
  end
end
