# Version 2.0: whether the Chapter tabs run along the top or down the left.
class AddChapterTabsSideToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :chapter_tabs_side, :string, null: false, default: "top"
  end
end
