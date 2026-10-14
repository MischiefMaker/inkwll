# Areas group rooms ("Settings") and can sit inside other areas, as deep as a
# game likes. Characters are never in an area, only in a room.
class CreateAreas < ActiveRecord::Migration[8.1]
  def up
    create_table :areas do |t|
      t.string :name, null: false
      t.text :description
      t.references :parent, foreign_key: { to_table: :areas }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_reference :rooms, :area, foreign_key: true

    # Every room must belong to an area. Put any existing rooms in a first one.
    if select_value("SELECT COUNT(*) FROM rooms").to_i > 0
      area_id = insert("INSERT INTO areas (name, position, created_at, updated_at) VALUES ('The World', 0, NOW(), NOW())")
      execute("UPDATE rooms SET area_id = #{area_id.to_i}")
    end

    change_column_null :rooms, :area_id, false
  end

  def down
    remove_reference :rooms, :area
    drop_table :areas
  end
end
