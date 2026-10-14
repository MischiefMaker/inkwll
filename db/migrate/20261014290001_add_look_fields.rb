# The simpler, more customisable look (owner, 2026-10-14): Areas and
# Settings get an optional short text (the long text is the existing
# description), and the game gets a name and a short blurb for the front page.
# Icons, banners and background images are Active Storage attachments, so
# they need no columns.
class AddLookFields < ActiveRecord::Migration[8.1]
  def change
    add_column :areas, :summary, :string
    add_column :rooms, :summary, :string
    add_column :game_settings, :game_name, :string
    add_column :game_settings, :game_blurb, :text
  end
end
