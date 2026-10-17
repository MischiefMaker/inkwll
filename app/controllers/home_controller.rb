# The front page: the game's name and blurb, then its top-level Areas.
# "Enter" takes the character to an Area's entrance Setting, and players walk
# the Paths from there.
class HomeController < ApplicationController
  allow_previews
  def show
    @areas = Area.top_level.with_attached_image.with_attached_icon
    # Players seen in the last few minutes. Where lists their characters.
    @online = Account.where(last_seen_at: 10.minutes.ago..).where(system: false)
      .includes(active_character: :character_group, icon_attachment: { blob: { variant_records: { image_attachment: :blob } } }).order(:display_name).to_a
  end
end
