class AddPlatformSettings < ActiveRecord::Migration[8.1]
  def change
    change_table :game_settings, bulk: true do |t|
      t.boolean :wiki_enabled, default: true, null: false
      t.jsonb :skin_colours, default: {}, null: false
      t.jsonb :skin_dark_colours, default: {}, null: false
      t.boolean :skin_dark_mode, default: true, null: false
      t.string :font_body
      t.string :font_heading
      t.text :custom_css
    end
  end
end
