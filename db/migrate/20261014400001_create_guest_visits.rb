# Visitors who aren't logged in can preview the grid. Each one's latest
# Setting is noted for a few minutes so "Here" can show "Guest" or "3 Guests".
class CreateGuestVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_visits do |t|
      t.string :token, null: false
      t.references :room, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :seen_at, null: false
    end
    add_index :guest_visits, :token, unique: true
    add_index :guest_visits, :seen_at
  end
end
