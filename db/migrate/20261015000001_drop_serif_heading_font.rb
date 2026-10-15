# The Slate blue and gold and Black and red looks no longer use a serif font
# for headings (owner). Games that still have the old one get the plain
# sans-serif font instead; a heading font someone typed in themselves stays.
class DropSerifHeadingFont < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE game_settings SET font_heading = NULL WHERE font_heading = 'Georgia, ''Times New Roman'', serif'"
  end

  def down
  end
end
