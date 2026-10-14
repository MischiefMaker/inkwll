# Which ready-made look a game last started from (owner, 2026-10-14). Some
# looks, like the old-school MUSH one, come with extra styling of their own
# (app/assets/stylesheets/skin-mush.css), switched on by a class on <body>
# that stays even if the game then tweaks a colour.
class AddSkinBaseToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :skin_base, :string
  end
end
