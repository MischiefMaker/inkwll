# Web fonts a game brings with it, from an imported world pack. Each is one
# font file for one family, weight and style, served from the game itself
# (the content security policy doesn't allow font sites). See SkinFont.
class CreateSkinFonts < ActiveRecord::Migration[8.1]
  def change
    create_table :skin_fonts do |t|
      t.references :game_setting, null: false, foreign_key: true
      t.string :family, null: false
      t.integer :weight, null: false, default: 400
      t.string :style, null: false, default: "normal"
      t.timestamps
    end
    add_index :skin_fonts, %i[ game_setting_id family weight style ], unique: true, name: "index_skin_fonts_on_face"
  end
end
