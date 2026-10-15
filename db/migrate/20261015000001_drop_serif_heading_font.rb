# The default look (Slate blue and gold) now uses the plain sans-serif font
# for headings (owner, 2026-10-15). Games on that look that still have its
# old Georgia headings switch over; a heading font typed in by hand stays.
class DropSerifHeadingFont < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE game_settings SET font_heading = NULL
      WHERE skin_base = 'wild' AND font_heading = 'Georgia, ''Times New Roman'', serif'
    SQL
  end

  def down
  end
end
