# The other games (Wells) the Founder runs from this one's Wells page. This
# game itself isn't a row; it's always listed first. See docs/wells.md.
class CreateWells < ActiveRecord::Migration[8.1]
  def change
    create_table :wells do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :domain, null: false, index: { unique: true }
      t.string :setup_code, null: false
      t.string :status, null: false, default: "starting"
      t.string :version
      t.references :account, null: false, foreign_key: true
      t.timestamps
    end
    add_reference :well_updates, :well, foreign_key: true
    add_column :well_updates, :first_time, :boolean, null: false, default: false
  end
end
