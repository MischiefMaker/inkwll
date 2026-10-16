class AddChapterLayoutToGameSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :chapter_layout, :string, default: "manuscript", null: false
    add_column :game_settings, :chapter_cast_portraits, :string, default: "large", null: false
    add_column :game_settings, :chapter_passage_portraits, :string, default: "small", null: false
  end
end
