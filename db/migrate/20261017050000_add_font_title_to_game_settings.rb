# A third font box in Admin → Look: the font for big titles (the game's name
# on the front page, forum section titles), beside text and headings.
class AddFontTitleToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :font_title, :string
  end
end
